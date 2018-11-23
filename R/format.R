#' Format stats19 'accidents' data
#'
#' @section Details:
#' This is a helper function to format raw stats19 data
#'
#' @param x Data frame created with `read_accidents()`
#' @param factorize Should some results be returned as factors? `FALSE` by default
#' @export
#' @examples
#' \dontrun{
#' x = read_accidents()
#' sapply(x, class)
#' table(x$Accident_Severity)
#' crashes = format_accidents(x)
#' sapply(crashes, class)
#' table(crashes$accident_severity)
#' }
#' @export
format_accidents = function(x, factorize = FALSE) {
  old_names = names(x)
  new_names = format_column_names(old_names)
  names(x) = new_names

  # create lookup table
  lkp = stats19_variables[stats19_variables$table == "accidents", ]
  lkp = lkp[lkp$type == "character", ]
  lkp$schema_variable = stats19_vname_switch(lkp$variable)
  lkp$new_name = gsub(pattern = " ", replacement = "_", lkp$schema_variable)
  lkp$new_name = stats19_vname_raw(lkp$new_name)

  vars_to_change = which(old_names %in% lkp$new_name)
  # old_names[vars_to_change]

  # # testing:
  # perfect_matches = lkp$new_name %in% old_names
  # summary(perfect_matches)
  # lkp$new_name[perfect_matches]
  # lkp$new_name[!perfect_matches]

  # format 1 column for testing
  # col_name_tmp = "accident_severity"
  # sel_col = agrep(pattern = col_name_tmp, x = stats19_schema$variable, max.distance = 3)
  # lookup_col_name = stats19_schema$variable[sel_col]
  # lookup = stats19_schema[stats19_schema$variable == lookup_col_name, 1:2]
  # x$accident_severity = lookup$label[match(x$accident_severity, lookup$code)]

  # doing it as a for loop for now as easier to debug - could convert to lapply
  i = 1 # for testing
  i = 6 # for testing
  for(i in vars_to_change) {
    # format 1 column for testing
    lookup_col_name = lkp$schema_variable[lkp$new_name == old_names[i]]
    lookup = stats19_schema[stats19_schema$variable == lookup_col_name, 1:2]
    if(nrow(lookup) != 0) {
      message("No single match for ", lookup_col_name)
    }
    x[[i]] = lookup$label[match(x[[i]], lookup$code)]
  }
  x
}
#' Format column names of raw stats19 data
#'
#' This function takes messy column names and returns clean ones that work well with
#' R by default. Names that are all lower case with no R-unfriendly characters
#' such as spaces and `-` are returned.
#' @param column_names Column names to be cleaned
#' @export
#' @examples \dontrun{
#' crashes_raw = read_accidents()
#' column_names = names(crashes_raw)
#' column_names
#' format_column_names(column_names = column_names)
#' }
format_column_names = function(column_names) {
  x = tolower(column_names)
  x = gsub(pattern = " ", replacement = "_", x = x)
  x = gsub(pattern = "\\(|\\)", replacement = "", x = x)
  x = gsub(pattern = "1st", replacement = "first", x = x)
  x = gsub(pattern = "2nd", replacement = "second", x = x)
  x = gsub(pattern = "-", replacement = "_", x = x)
  x
}
#' Load stats19 schema
#'
#' This function generates the data object `stats19_schema` in a reproducible way
#' using DfT's schema definition (see function [dl_schema()]).
#'
#' The function also generates `stats19_variables`
#' (see the function's source code for details).
#'
#' @inheritParams read_accidents
#' @param sheet integer to be added if you want to download a single sheet
#' @export
#' @examples \dontrun{
#' stats19_schema = read_schema()
#' }
read_schema = function(
  data_dir = tempdir(),
  filename = "Road-Accident-Safety-Data-Guide.xls",
  sheet = NULL
  ) {
  file_path = file.path(data_dir, filename)
  if (!file.exists(file_path)) {
    dl_schema()
  }
  if(is.null(sheet)) {
    export_variables = readxl::read_xls(path = file_path, sheet = 2, skip = 2)
    export_variables_accidents = data.frame(
      stringsAsFactors = FALSE,
      table = "accidents",
      variable = export_variables$`Accident Circumstances`
        )
    export_variables_vehicles = data.frame(
      stringsAsFactors = FALSE,
      table = "vehicles",
      variable = export_variables$Vehicle
    )
    export_variables_casualties = data.frame(
      stringsAsFactors = FALSE,
      table = "casualties",
      variable = export_variables$Casualty
    )
    export_variables_long = rbind(
      export_variables_accidents,
      export_variables_casualties,
      export_variables_vehicles
    )
    stats19_variables = stats::na.omit(export_variables_long)
    # stats19_variables$variable_name = format_column_names(stats19_variables$variable)
    stats19_variables$type = stats19_vtype(stats19_variables$variable)

    # export result:
    # usethis::use_data(stats19_variables, overwrite = TRUE)

    # test results:
    # sheet_name = stats19_variables$variable[2]
    # schema_1 = readxl::read_xls(path = file_path, sheet = sheet_name)

    sel_character = stats19_variables$type == "character"

    character_vars = stats19_variables$variable[sel_character]
    character_vars = stats19_vname_switch(character_vars)

    schema_list = lapply(
      X = 1:length(character_vars),
      FUN = function(i) {
        x = readxl::read_xls(path = file_path, sheet = character_vars[i])
        # x$code = as.character(x$code)
        names(x) = c("code", "label")
        x
      }
    )

    stats19_schema = do.call(what = rbind, args = schema_list)
    n_categories = sapply(schema_list, nrow)
    stats19_schema$variable = rep(character_vars, n_categories)

    # test result
    sel_schema_in_variables = stats19_schema$variable %in% stats19_variables$variable
    sel_variables_in_schema = stats19_variables$variable %in% stats19_schema$variable
    unique(stats19_schema$variable[!sel_schema_in_variables]) # variables have better names
    unique(stats19_variables$variable[!sel_variables_in_schema])

  } else {
    stats19_schema = readxl::read_xls(path = file_path, sheet = sheet)
  }
  stats19_schema
}
# Return type of variable of stats19 data - informal test:
# variable_types = stats19_vtype(stats19_variables$variable)
# names(variable_types) = stats19_variables$variable
# variable_types
# x = names(read_accidents())
# n = stats19_vtype(x)
# names(n) = x
# n
stats19_vtype = function(x) {
  variable_types = rep("character", length(x))
  sel_numeric = grepl(pattern = "Number|Speed|Age*.of|Capacity", x = x)
  variable_types[sel_numeric] = "numeric"
  sel_date = grepl(pattern = "^Date", x = x)
  variable_types[sel_date] = "date"
  sel_time = grepl(pattern = "^Time", x = x)
  variable_types[sel_time] = "time"
  sel_location = grepl(pattern = "^Location|Longi|Lati", x = x)
  variable_types[sel_location] = "location"
  # remove other variables with no lookup: no weather ?!
  sel_other = grepl(
    pattern = "Did|Lower|Accident*.Ind|Reference|Restricted|Leaving|Hit|Age*.Band*.of*.D|Driver*.[H|I]",
    x = x
  )
  variable_types[sel_other] = "other"
  variable_types
}

stats19_vname_switch = function(x) {
  x = gsub(pattern = " Authority - ONS code", "", x = x)
  x = gsub(pattern = "Pedestrian Crossing-Human Control", "Ped Cross - Human", x = x)
  x = gsub(pattern = "Pedestrian Crossing-Physical Facilities", "Ped Cross - Physical", x = x)
  x = gsub(pattern = "r Conditions", "r", x = x)
  x = gsub(pattern = "e Conditions", "e", x = x)
  x = gsub(pattern = " Area|or ", "", x = x)
  x = gsub(pattern = "Age Band of Casualty", "Age Band", x = x)
  x = gsub(pattern = "Pedestrian", "Ped", x = x)
  x = gsub(pattern = "Bus Coach Passenger", "Bus Passenger", x = x)
  x = gsub(pattern = " \\(From 2011\\)", "", x = x)
  x = gsub(pattern = "Casualty Home Type", "Home Area Type", x = x)
  x = gsub(pattern = "Casualty IMD Decile", "IMD Decile", x = x)
  x = gsub(pattern = "Journey Purpose of Driver", "Journey Purpose", x = x)
  x
}

stats19_vname_raw = function(x) {
  x = gsub(pattern = "Ped_Cross_-_Human", "Pedestrian_Crossing-Human_Control", x = x)
  x = gsub(pattern = "Ped_Cross_-_Physical", "Pedestrian_Crossing-Physical_Facilities", x = x)
  x = gsub(pattern = "Weather", "Weather_Conditions", x = x)
  x = gsub(pattern = "Road_Surface", "Road_Surface_Conditions", x = x)
  x = gsub(pattern = "Urban_Rural", "Urban_or_Rural_Area", x = x)
  x
}

schema_to_variable = function(x) {
  x = gsub()
}