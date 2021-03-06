% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_vehicles}
\alias{read_vehicles}
\title{Import and Stats19 data on vehicles}
\usage{
read_vehicles(filename = NULL, data_dir = tempdir(), year = NULL)
}
\arguments{
\item{filename}{Character string of the filename of the .csv to read, if this is given, type and
years determine whether there is a target to read, otherwise disk scan would be needed.}

\item{data_dir}{Where sets of downloaded data would be found.}

\item{year}{Single year for which data are to be read}
}
\description{
Import and Stats19 data on vehicles
}
\section{Details}{

The function returns a data frame, in which each record is a reported vehicle in the
stats19 dataset for the data_dir and filename provided.
}

\examples{
\dontrun{
ve = read_vehicles()
}
}
