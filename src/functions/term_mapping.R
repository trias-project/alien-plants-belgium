term_mapping <- function(lookup_table, term) {
  # Filter lookup table on term (expected to be first column)
  
  # Unfortunately we cannot pass 'term' as a variable to 
  # filter(lookup_table[[1]] == term)
  # So, we need to create the condition as a string and pass to filter_()
  condition <- paste0(colnames(lookup_table)[[1]], "==\"", term, "\"")
  # e.g. 'term == "locationID"'
  
  term_lookup_table <- filter_(lookup_table, condition)
  
  # Throw error if filter returns no results
  if (nrow(term_lookup_table) == 0) stop(paste0("Term \"", term, "\" not found in first column of lookup table."))
  
  # Create list with new values (expected to be 3rd column) as values
  term_map <- as.vector(term_lookup_table[[3]])
  # And lookup values (expected to be 2nd column) as names
  term_map <- setNames(term_map, term_lookup_table[[2]])
  
  return(term_map)
}
