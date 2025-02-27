% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/centralization.R
\name{centr_degree_tmax}
\alias{centr_degree_tmax}
\alias{centralization.degree.tmax}
\title{Theoretical maximum for degree centralization}
\usage{
centr_degree_tmax(
  graph = NULL,
  nodes = 0,
  mode = c("all", "out", "in", "total"),
  loops = FALSE
)
}
\arguments{
\item{graph}{The input graph. It can also be \code{NULL}, if
\code{nodes}, \code{mode} and \code{loops} are all given.}

\item{nodes}{The number of vertices. This is ignored if the graph is given.}

\item{mode}{This is the same as the \code{mode} argument of
\code{degree()}.}

\item{loops}{Logical scalar, whether to consider loops edges when
calculating the degree. Currently the default value is \code{FALSE},
but this argument will be required from igraph 1.4.0.}
}
\value{
Real scalar, the theoretical maximum (unnormalized) graph degree
centrality score for graphs with given order and other parameters.
}
\description{
See \code{\link[=centralize]{centralize()}} for a summary of graph centralization.
}
\examples{
# A BA graph is quite centralized
g <- sample_pa(1000, m = 4)
centr_degree(g, normalized = FALSE)$centralization \%>\%
  `/`(centr_degree_tmax(g, loops = FALSE))
centr_degree(g, normalized = TRUE)$centralization
}
\seealso{
Other centralization related: 
\code{\link{centr_betw_tmax}()},
\code{\link{centr_betw}()},
\code{\link{centr_clo_tmax}()},
\code{\link{centr_clo}()},
\code{\link{centr_degree}()},
\code{\link{centr_eigen_tmax}()},
\code{\link{centr_eigen}()},
\code{\link{centralize}()}
}
\concept{centralization related}
