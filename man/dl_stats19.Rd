% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dl_stats19.R
\name{dl_stats19}
\alias{dl_stats19}
\title{Download Stats19 data for a year or range of two years.}
\usage{
dl_stats19(years = "", type = "Accidents")
}
\arguments{
\item{years}{Either a single year or a two year range, defaults to 2 years ago}

\item{type}{One of 'Accidents', 'Casualties', 'Vehicles'; defaults to 'Accidents'#' @export}
}
\description{
Download Stats19 data for a year or range of two years.
}
\section{Details}{

This convenient function downloads and unzips UK road traffic casualty data.
It results in unzipped .csv data in R's temporary directory.

Ensure you have a fast internet connection and at least 100 Mb space
}

\examples{
\dontrun{
dl_stats19()
# now you can analyse the UK's stats19 data in a single table
}
}