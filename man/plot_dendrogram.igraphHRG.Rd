% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hrg.R
\name{plot_dendrogram.igraphHRG}
\alias{plot_dendrogram.igraphHRG}
\alias{hrg.dendrogram}
\title{HRG dendrogram plot}
\usage{
\method{plot_dendrogram}{igraphHRG}(x, mode = igraph_opt("dend.plot.type"), ...)
}
\arguments{
\item{x}{An \code{igraphHRG}, a hierarchical random graph, as returned by
the \code{\link[=fit_hrg]{fit_hrg()}} function.}

\item{mode}{Which dendrogram plotting function to use. See details below.}

\item{\dots}{Additional arguments to supply to the dendrogram plotting
function.}
}
\value{
Returns whatever the return value was from the plotting function,
\code{plot.phylo}, \code{plot.dendrogram} or \code{plot.hclust}.
}
\description{
Plot a hierarchical random graph as a dendrogram.
}
\details{
\code{plot_dendrogram()} supports three different plotting functions, selected via
the \code{mode} argument. By default the plotting function is taken from the
\code{dend.plot.type} igraph option, and it has for possible values:
\itemize{ \item \code{auto} Choose automatically between the plotting
functions. As \code{plot.phylo} is the most sophisticated, that is choosen,
whenever the \code{ape} package is available. Otherwise \code{plot.hclust}
is used.  \item \code{phylo} Use \code{plot.phylo} from the \code{ape}
package.  \item \code{hclust} Use \code{plot.hclust} from the \code{stats}
package.  \item \code{dendrogram} Use \code{plot.dendrogram} from the
\code{stats} package.  }

The different plotting functions take different sets of arguments. When
using \code{plot.phylo} (\code{mode="phylo"}), we have the following syntax:
\preformatted{
    plot_dendrogram(x, mode="phylo", colbar = rainbow(11, start=0.7,
            end=0.1), edge.color = NULL, use.edge.length = FALSE, \dots)
} The extra arguments not documented above: \itemize{
\item \code{colbar} Color bar for the edges.
\item \code{edge.color} Edge colors. If \code{NULL}, then the
\code{colbar} argument is used.
\item \code{use.edge.length} Passed to \code{plot.phylo}.
\item \code{dots} Attitional arguments to pass to \code{plot.phylo}.
}

The syntax for \code{plot.hclust} (\code{mode="hclust"}): \preformatted{
    plot_dendrogram(x, mode="hclust", rect = 0, colbar = rainbow(rect),
            hang = 0.01, ann = FALSE, main = "", sub = "", xlab = "",
            ylab = "", \dots)
} The extra arguments not documented above: \itemize{
\item \code{rect} A numeric scalar, the number of groups to mark on
the dendrogram. The dendrogram is cut into exactly \code{rect}
groups and they are marked via the \code{rect.hclust} command. Set
this to zero if you don't want to mark any groups.
\item \code{colbar} The colors of the rectangles that mark the
vertex groups via the \code{rect} argument.
\item \code{hang} Where to put the leaf nodes, this corresponds to the
\code{hang} argument of \code{plot.hclust}.
\item \code{ann} Whether to annotate the plot, the \code{ann} argument
of \code{plot.hclust}.
\item \code{main} The main title of the plot, the \code{main} argument
of \code{plot.hclust}.
\item \code{sub} The sub-title of the plot, the \code{sub} argument of
\code{plot.hclust}.
\item \code{xlab} The label on the horizontal axis, passed to
\code{plot.hclust}.
\item \code{ylab} The label on the vertical axis, passed to
\code{plot.hclust}.
\item \code{dots} Attitional arguments to pass to \code{plot.hclust}.
}

The syntax for \code{plot.dendrogram} (\code{mode="dendrogram"}):
\preformatted{
    plot_dendrogram(x, \dots)
} The extra arguments are simply passed to \code{\link[=as.dendrogram]{as.dendrogram()}}.
}
\examples{

g <- make_full_graph(5) + make_full_graph(5)
hrg <- fit_hrg(g)
plot_dendrogram(hrg)

}
\author{
Gabor Csardi \email{csardi.gabor@gmail.com}
}
\keyword{graphs}
