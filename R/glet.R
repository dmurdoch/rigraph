
#' Graphlet decomposition of a graph
#'
#' Graphlet decomposition models a weighted undirected graph via the union of
#' potentially overlapping dense social groups.  This is done by a two-step
#' algorithm. In the first step a candidate set of groups (a candidate basis)
#' is created by finding cliques if the thresholded input graph. In the second
#' step these the graph is projected on the candidate basis, resulting a weight
#' coefficient for each clique in the candidate basis.
#'
#' igraph contains three functions for performing the graph decomponsition of a
#' graph. The first is `graphlets()`, which performed both steps on the
#' method and returns a list of subgraphs, with their corresponding weights.
#' The second and third functions correspond to the first and second steps of
#' the algorithm, and they are useful if the user wishes to perform them
#' individually: `graphlet_basis()` and `graphlet_proj()`.
#'
#' @aliases graphlets.project graphlets.candidate.basis
#' @param graph The input graph, edge directions are ignored. Only simple graph
#'   (i.e. graphs without self-loops and multiple edges) are supported.
#' @param weights Edge weights. If the graph has a `weight` edge attribute
#'   and this argument is `NULL` (the default), then the `weight` edge
#'   attribute is used.
#' @param niter Integer scalar, the number of iterations to perform.
#' @param cliques A list of vertex ids, the graphlet basis to use for the
#'   projection.
#' @param Mu Starting weights for the projection.
#' @return `graphlets()` returns a list with two members: \item{cliques}{A
#'   list of subgraphs, the candidate graphlet basis. Each subgraph is give by a
#'   vector of vertex ids.} \item{Mu}{The weights of the subgraphs in graphlet
#'   basis.}
#'
#'   `graphlet_basis()` returns a list of two elements: \item{cliques}{A list
#'   of subgraphs, the candidate graphlet basis. Each subgraph is give by a
#'   vector of vertex ids.} \item{thresholds}{The weight thresholds used for
#'   finding the subgraphs.}
#'
#'   `graphlet_proj()` return a numeric vector, the weights of the graphlet
#'   basis subgraphs.
#' @examples
#'
#' ## Create an example graph first
#' D1 <- matrix(0, 5, 5)
#' D2 <- matrix(0, 5, 5)
#' D3 <- matrix(0, 5, 5)
#' D1[1:3, 1:3] <- 2
#' D2[3:5, 3:5] <- 3
#' D3[2:5, 2:5] <- 1
#'
#' g <- simplify(graph_from_adjacency_matrix(D1 + D2 + D3,
#'   mode = "undirected", weighted = TRUE
#' ))
#' V(g)$color <- "white"
#' E(g)$label <- E(g)$weight
#' E(g)$label.cex <- 2
#' E(g)$color <- "black"
#' layout(matrix(1:6, nrow = 2, byrow = TRUE))
#' co <- layout_with_kk(g)
#' par(mar = c(1, 1, 1, 1))
#' plot(g, layout = co)
#'
#' ## Calculate graphlets
#' gl <- graphlets(g, niter = 1000)
#'
#' ## Plot graphlets
#' for (i in 1:length(gl$cliques)) {
#'   sel <- gl$cliques[[i]]
#'   V(g)$color <- "white"
#'   V(g)[sel]$color <- "#E495A5"
#'   E(g)$width <- 1
#'   E(g)[V(g)[sel] %--% V(g)[sel]]$width <- 2
#'   E(g)$label <- ""
#'   E(g)[width == 2]$label <- round(gl$Mu[i], 2)
#'   E(g)$color <- "black"
#'   E(g)[width == 2]$color <- "#E495A5"
#'   plot(g, layout = co)
#' }
#' @family glet
#' @export
graphlet_basis <- function(graph, weights = NULL) {
  ## Argument checks
  ensure_igraph(graph)
  if (is.null(weights) && "weight" %in% edge_attr_names(graph)) {
    weights <- E(graph)$weight
  }
  if (!is.null(weights) && any(!is.na(weights))) {
    weights <- as.numeric(weights)
  } else {
    weights <- NULL
  }

  ## Drop all attributes, we don't want to deal with them, TODO
  graph2 <- graph
  graph2[[igraph_t_idx_attr]] <- list(c(1, 0, 1), list(), list(), list())

  on.exit(.Call(R_igraph_finalizer))
  ## Function call
  res <- .Call(R_igraph_graphlets_candidate_basis, graph2, weights)

  res
}

#' @rdname graphlet_basis
#' @export
graphlet_proj <- function(graph, weights = NULL, cliques, niter = 1000,
                          Mu = rep(1, length(cliques))) {
  # Argument checks
  ensure_igraph(graph)
  if (is.null(weights) && "weight" %in% edge_attr_names(graph)) {
    weights <- E(graph)$weight
  }
  if (!is.null(weights) && any(!is.na(weights))) {
    weights <- as.numeric(weights)
  } else {
    weights <- NULL
  }
  Mu <- as.numeric(Mu)
  niter <- as.numeric(niter)

  on.exit(.Call(R_igraph_finalizer))
  # Function call
  res <- .Call(R_igraph_graphlets_project, graph, weights, cliques, Mu, niter)

  res
}

#################
## Example code

function() {
  library(igraph)

  fitandplot <- function(g, gl) {
    g <- simplify(g)
    V(g)$color <- "white"
    E(g)$label <- E(g)$weight
    E(g)$label.cex <- 2
    E(g)$color <- "black"
    plot.new()
    layout(matrix(1:6, nrow = 2, byrow = TRUE))
    co <- layout_with_kk(g)
    par(mar = c(1, 1, 1, 1))
    plot(g, layout = co)
    for (i in 1:length(gl$Bc)) {
      sel <- gl$Bc[[i]]
      V(g)$color <- "white"
      V(g)[sel]$color <- "#E495A5"
      E(g)$width <- 1
      E(g)[V(g)[sel] %--% V(g)[sel]]$width <- 2
      E(g)$label <- ""
      E(g)[width == 2]$label <- round(gl$Muc[i], 2)
      E(g)$color <- "black"
      E(g)[width == 2]$color <- "#E495A5"
      plot(g, layout = co)
    }
  }

  D1 <- matrix(0, 5, 5)
  D2 <- matrix(0, 5, 5)
  D3 <- matrix(0, 5, 5)
  D1[1:3, 1:3] <- 2
  D2[3:5, 3:5] <- 3
  D3[2:5, 2:5] <- 1

  g <- graph_from_adjacency_matrix(D1 + D2 + D3, mode = "undirected", weighted = TRUE)
  gl <- graphlets(g, iter = 1000)

  fitandplot(g, gl)

  ## Project another graph on the graphlets
  set.seed(42)
  g2 <- set_edge_attr(g, "weight", value = sample(E(g)$weight))
  gl2 <- graphlet_proj(g2, gl$Bc, 1000)
  fitandplot(g2, gl2)
}

#' @rdname graphlet_basis
#' @export
graphlets <- graphlets_impl
#' @export graphlets.candidate.basis
deprecated("graphlets.candidate.basis", graphlet_basis)
#' @export graphlets.project
deprecated("graphlets.project", graphlet_proj)
