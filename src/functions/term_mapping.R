term_mapping <- function(lookup_table, term) {
  # The lookup table is expected to have 3 columns: term, lookup_value, new_value
  # e.g. occurrenceStatus, ?, presence uncertain
  # The column names don't matter, their position does.
  
  # FILTER
  # Filter the lookup table on the chosen term (column 1)
  condition <- paste0(colnames(lookup_table)[[1]], "==\"", term, "\"")
  # In the above statement we need need to pass the condition as a string, e.g.
  # 'term == "locationID"' because this unfortunately doesn't work: 
  # filter(lookup_table[[1]] == term)
  term_lookup_table <- filter_(lookup_table, condition)
  
  # Throw error if filter returns no results
  if (nrow(term_lookup_table) == 0) stop(paste0("Term \"", term, "\" not found in first column of lookup table."))
  
  # NEW VALUES
  # Create a list from the new values (column 3)
  new_values <- as.vector(term_lookup_table[[3]])
  term_map <- new_values
  
  # LOOKUP VALUES
  # Create a list from the lookup values (column 2)
  lookup_values <- as.vector(term_lookup_table[[2]])
  
  # Replace empty lookup values with ".missing", which allows these to be mapped
  # later with the dplyr::recode()
  lookup_values[lookup_values == ""] <- ".missing"
  
  # Throw error if there are duplicate lookup values
  if (any(duplicated(lookup_values))) stop(paste0("Duplicate lookup values found for \"", term, "\"."))
  
  # Set lookup values as names for the new values
  term_map <- setNames(term_map, lookup_values)

  return(term_map)
}
