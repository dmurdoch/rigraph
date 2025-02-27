
## ----------------------------------------------------------------
##
##   IGraph R package
##   Copyright (C) 2005-2014  Gabor Csardi <csardi.gabor@gmail.com>
##   334 Harvard street, Cambridge, MA 02139 USA
##
##   This program is free software; you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation; either version 2 of the License, or
##   (at your option) any later version.
##
##   This program is distributed in the hope that it will be useful,
##   but WITHOUT ANY WARRANTY; without even the implied warranty of
##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##   GNU General Public License for more details.
##
##   You should have received a copy of the GNU General Public License
##   along with this program; if not, write to the Free Software
##   Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
##   02110-1301 USA
##
## -----------------------------------------------------------------

graph.incidence.sparse <- function(incidence, directed, mode, multiple,
                                   weighted) {
  n1 <- nrow(incidence)
  n2 <- ncol(incidence)
  el <- mysummary(incidence)
  el[, 2] <- el[, 2] + n1

  if (!is.null(weighted)) {
    if (is.logical(weighted) && weighted) {
      weighted <- "weight"
    }
    if (!is.character(weighted)) {
      stop("invalid value supplied for `weighted' argument, please see docs.")
    }

    if (!directed || mode == 1) {
      ## nothing do to
    } else if (mode == 2) {
      el[, 1:2] <- el[, c(2, 1)]
    } else if (mode == 3) {
      reversed_el <- el[, c(2, 1, 3)]
      names(reversed_el) <- names(el)
      el <- rbind(el, reversed_el)
    }

    res <- make_empty_graph(n = n1 + n2, directed = directed)
    weight <- list(el[, 3])
    names(weight) <- weighted
    res <- add_edges(res, edges = t(as.matrix(el[, 1:2])), attr = weight)
  } else {
    if (multiple) {
      el[, 3] <- ceiling(el[, 3])
      el[, 3][el[, 3] < 0] <- 0
    } else {
      el[, 3] <- el[, 3] != 0
    }

    if (!directed || mode == 1) {
      ## nothing do to
    } else if (mode == 2) {
      el[, 1:2] <- el[, c(2, 1)]
    } else if (mode == 3) {
      el <- rbind(el, el[, c(2, 1, 3)])
    }

    edges <- unlist(apply(el, 1, function(x) rep(unname(x[1:2]), x[3])))
    res <- make_graph(n = n1 + n2, edges, directed = directed)
  }

  set_vertex_attr(res, "type", value = c(rep(FALSE, n1), rep(TRUE, n2)))
}

graph.incidence.dense <- function(incidence, directed, mode, multiple,
                                  weighted) {
  if (!is.null(weighted)) {
    if (is.logical(weighted) && weighted) {
      weighted <- "weight"
    }
    if (!is.character(weighted)) {
      stop("invalid value supplied for `weighted' argument, please see docs.")
    }

    n1 <- nrow(incidence)
    n2 <- ncol(incidence)
    no.edges <- sum(incidence != 0)
    if (directed && mode == 3) {
      no.edges <- no.edges * 2
    }
    edges <- numeric(2 * no.edges)
    weight <- numeric(no.edges)
    ptr <- 1
    for (i in seq_len(nrow(incidence))) {
      for (j in seq_len(ncol(incidence))) {
        if (incidence[i, j] != 0) {
          if (!directed || mode == 1) {
            edges[2 * ptr - 1] <- i
            edges[2 * ptr] <- n1 + j
            weight[ptr] <- incidence[i, j]
            ptr <- ptr + 1
          } else if (mode == 2) {
            edges[2 * ptr - 1] <- n1 + j
            edges[2 * ptr] <- i
            weight[ptr] <- incidence[i, j]
            ptr <- ptr + 1
          } else if (mode == 3) {
            edges[2 * ptr - 1] <- i
            edges[2 * ptr] <- n1 + j
            weight[ptr] <- incidence[i, j]
            ptr <- ptr + 1
            edges[2 * ptr - 1] <- n1 + j
            edges[2 * ptr] <- i
            weight[ptr] <- incidence[i, j]
            ptr <- ptr + 1
          }
        }
      }
    }
    res <- make_empty_graph(n = n1 + n2, directed = directed)
    weight <- list(weight)
    names(weight) <- weighted
    res <- add_edges(res, edges, attr = weight)
    res <- set_vertex_attr(res, "type",
      value = c(rep(FALSE, n1), rep(TRUE, n2))
    )
  } else {
    mode(incidence) <- "double"
    on.exit(.Call(R_igraph_finalizer))
    ## Function call
    res <- .Call(R_igraph_incidence, incidence, directed, mode, multiple)
    res <- set_vertex_attr(res$graph, "type", value = res$types)
  }

  res
}

#' Create graphs from a bipartite adjacency matrix
#'
#' `graph_from_biadjacency_matrix()` creates a bipartite igraph graph from an incidence
#' matrix.
#'
#' Bipartite graphs have a \sQuote{`type`} vertex attribute in igraph,
#' this is boolean and `FALSE` for the vertices of the first kind and
#' `TRUE` for vertices of the second kind.
#'
#' `graph_from_biadjacency_matrix()` can operate in two modes, depending on the
#' `multiple` argument. If it is `FALSE` then a single edge is
#' created for every non-zero element in the bipartite adjacency matrix. If
#' `multiple` is `TRUE`, then the matrix elements are rounded up to
#' the closest non-negative integer to get the number of edges to create
#' between a pair of vertices.
#'
#' @aliases graph.incidence
#' @param incidence The input bipartite adjacency matrix. It can also be a sparse matrix
#'   from the `Matrix` package.
#' @param directed Logical scalar, whether to create a directed graph.
#' @param mode A character constant, defines the direction of the edges in
#'   directed graphs, ignored for undirected graphs. If \sQuote{`out`}, then
#'   edges go from vertices of the first kind (corresponding to rows in the
#'   bipartite adjacency matrix) to vertices of the second kind (columns in the incidence
#'   matrix). If \sQuote{`in`}, then the opposite direction is used. If
#'   \sQuote{`all`} or \sQuote{`total`}, then mutual edges are created.
#' @param multiple Logical scalar, specifies how to interpret the matrix
#'   elements. See details below.
#' @param weighted This argument specifies whether to create a weighted graph
#'   from the bipartite adjacency matrix. If it is `NULL` then an unweighted graph is
#'   created and the `multiple` argument is used to determine the edges of
#'   the graph. If it is a character constant then for every non-zero matrix
#'   entry an edge is created and the value of the entry is added as an edge
#'   attribute named by the `weighted` argument. If it is `TRUE` then a
#'   weighted graph is created and the name of the edge attribute will be
#'   \sQuote{`weight`}.
#' @param add.names A character constant, `NA` or `NULL`.
#'   `graph_from_biadjacency_matrix()` can add the row and column names of the incidence
#'   matrix as vertex attributes. If this argument is `NULL` (the default)
#'   and the bipartite adjacency matrix has both row and column names, then these are added
#'   as the \sQuote{`name`} vertex attribute. If you want a different vertex
#'   attribute for this, then give the name of the attributes as a character
#'   string. If this argument is `NA`, then no vertex attributes (other than
#'   type) will be added.
#' @return A bipartite igraph graph. In other words, an igraph graph that has a
#'   vertex attribute `type`.
#' @author Gabor Csardi \email{csardi.gabor@@gmail.com}
#' @seealso [make_bipartite_graph()] for another way to create bipartite
#' graphs
#' @keywords graphs
#' @examples
#'
#' inc <- matrix(sample(0:1, 15, repl = TRUE), 3, 5)
#' colnames(inc) <- letters[1:5]
#' rownames(inc) <- LETTERS[1:3]
#' graph_from_biadjacency_matrix(inc)
#'
#' @details
#' Some authors refer to the bipartite adjacency matrix as the
#' "bipartite incidence matrix". igraph 1.6.0 and later does not use
#' this naming to avoid confusion with the edge-vertex incidence matrix.
#' @family biadjacency
#' @export
graph_from_biadjacency_matrix <- function(incidence, directed = FALSE,
                                        mode = c("all", "out", "in", "total"),
                                        multiple = FALSE, weighted = NULL,
                                        add.names = NULL) {
  # Argument checks
  directed <- as.logical(directed)
  mode <- switch(igraph.match.arg(mode),
    "out" = 1,
    "in" = 2,
    "all" = 3,
    "total" = 3
  )
  multiple <- as.logical(multiple)

  if (inherits(incidence, "Matrix")) {
    res <- graph.incidence.sparse(incidence,
      directed = directed,
      mode = mode, multiple = multiple,
      weighted = weighted
    )
  } else {
    incidence <- as.matrix(incidence)
    res <- graph.incidence.dense(incidence,
      directed = directed, mode = mode,
      multiple = multiple, weighted = weighted
    )
  }

  ## Add names
  if (is.null(add.names)) {
    if (!is.null(rownames(incidence)) && !is.null(colnames(incidence))) {
      add.names <- "name"
    } else {
      add.names <- NA
    }
  } else if (!is.na(add.names)) {
    if (is.null(rownames(incidence)) || is.null(colnames(incidence))) {
      warning("Cannot add row- and column names, at least one of them is missing")
      add.names <- NA
    }
  }
  if (!is.na(add.names)) {
    res <- set_vertex_attr(res, add.names,
      value = c(rownames(incidence), colnames(incidence))
    )
  }
  res
}
#' Graph from incidence matrix
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `graph_from_incidence_matrix()` was renamed to `graph_from_biadjacency_matrix()` to create a more
#' consistent API.
#' @inheritParams graph_from_biadjacency_matrix
#' @keywords internal
#' @details
#' Some authors refer to the bipartite adjacency matrix as the
#' "bipartite incidence matrix". igraph 1.6.0 and later does not use
#' this naming to avoid confusion with the edge-vertex incidence matrix.
#' @export
from_incidence_matrix <- function(...) { # nocov start
   lifecycle::deprecate_soft("1.6.0", "graph_from_incidence_matrix()", "graph_from_biadjacency_matrix()")
   graph_from_biadjacency_matrix(...)
} # nocov end
#' From incidence matrix
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `graph_from_incidence_matrix()` was renamed to `graph_from_biadjacency_matrix()` to create a more
#' consistent API.
#' @inheritParams graph_from_biadjacency_matrix
#' @keywords internal
#' @details
#' Some authors refer to the bipartite adjacency matrix as the
#' "bipartite incidence matrix". igraph 1.6.0 and later does not use
#' this naming to avoid confusion with the edge-vertex incidence matrix.
#' @export
graph_from_incidence_matrix <- function(...) { # nocov start
   lifecycle::deprecate_soft("1.6.0", "graph_from_incidence_matrix()", "graph_from_biadjacency_matrix()")
   graph_from_biadjacency_matrix(...)
} # nocov end
#' @export graph.incidence
deprecated("graph.incidence", graph_from_biadjacency_matrix)
