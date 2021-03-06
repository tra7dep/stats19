#' Import and Stats19 data on road traffic casualties
#'
#' @section Details:
#' This is a wrapper function to access and load stats 19 data in a user-friendly way.
#' The function returns a data frame, in which each record is a reported incident in the
#' stats19 dataset.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determine whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year Single year for which data are to be read
#'
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(year = 2017, type = "Accidents")
#' ac = read_accidents(year = 2017)
#' }
read_accidents = function(filename = "",
                          data_dir = tempdir(),
                          year = NULL) {
  # check inputs
  if (!is.null (year))
    year = check_year (year)
  path = check_input_file(
    filename = filename,
    type = "accidents",
    data_dir = data_dir,
    year = year
  )
  message("Reading in: ")
  message(path)
  # read the data in
  suppressWarnings({
    ac = readr::read_csv(
      path,
      col_types = readr::cols(
        .default = readr::col_integer(),
        Accident_Index = readr::col_character(),
        Longitude = readr::col_double(),
        Latitude = readr::col_double(),
        Date = readr::col_character(),
        Time = readr::col_character(),
        `Local_Authority_(Highway)` = readr::col_character(),
        LSOA_of_Accident_Location = readr::col_character()
      )
    )
  })

  ac

}

#' Import and Stats19 data on vehicles
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported vehicle in the
#' stats19 dataset for the data_dir and filename provided.
#'
#' @inheritParams read_accidents
#'
#' @export
#' @examples
#' \dontrun{
#' ve = read_vehicles()
#' }
read_vehicles = function(filename = NULL,
                         data_dir = tempdir(),
                         year = NULL) {
  # check inputs
  year = check_year (year)
  path = check_input_file(
    filename = filename,
    type = "vehicles",
    data_dir = data_dir,
    year = year
  )
  # read the data in
  ve = readr::read_csv(path, col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character()
  ))
  ve
}

#' Import and Stats19 data on casualties
#'
#' @section Details:
#' The function returns a data frame, in which each record is a reported casualty
#' in the stats19 dataset.
#'
#' @inheritParams read_accidents
#'
#' @export
#' @examples
#' \dontrun{
#' dl_stats19(years = 2017, type = "casualties")
#' casualties = read_casualties()
#' }
read_casualties = function(filename = NULL,
                           data_dir = tempdir(),
                           year = NULL) {

  # check inputs
  year = check_year (year)
  path = check_input_file(
    filename = filename,
    type = "casualties",
    data_dir = data_dir,
    year = year
  )
  # read the data in
  ca = readr::read_csv(path, col_types = readr::cols(
    .default = readr::col_integer(),
    Accident_Index = readr::col_character()
  ))
  ca
}

#' Local helper to be reused.
#'
#' @param filename Character string of the filename of the .csv to read, if this is given, type and
#' years determine whether there is a target to read, otherwise disk scan would be needed.
#' @param data_dir Where sets of downloaded data would be found.
#' @param year single year for which data are to be read
#' @param type One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'#'
#'
check_input_file = function(filename = NULL,
                            type = NULL,
                            data_dir = NULL,
                            year = NULL) {
  year = check_year (year)
  path = locate_one_file(
    type = type,
    filename = filename,
    data_dir = data_dir,
    year = year
  )
  # have we NOT found a csv to read?
  if (!endsWith(path, ".csv") | !file.exists(path)) {
    # locate_files malfunctioned or just foo/bar path returned with no filename
    message(path)
    stop("Change data_dir, filename, year or run dl_stats19() first.")
  }
  return(path)
}
