test_that("is_tree works for non-trees", {
  skip("Waiting for #935")

  g <- make_graph("zachary")
  expect_false(is_tree(g))
  expect_equal(
    ignore_attr = TRUE,
    is_tree(g, details = TRUE),
    list(res = FALSE, root = V(g)[1])
  )

  g <- sample_pa(15, m = 3)
  expect_false(is_tree(g))
  expect_false(is_tree(g, details = TRUE)$res)
})

test_that("is_tree works for undirected trees", {
  # g <- permute(make_tree(7, 2), c(5, 2, 3, 4, 1, 6, 7))
  g <- make_tree(7, 2)
  expect_true(is_tree(g))
  expect_equal(ignore_attr = TRUE, is_tree(g, details = TRUE), list(res = TRUE, root = V(g)[1]))
})

test_that("is_tree works for directed in-trees", {
  g <- permute(make_tree(7, 2, mode = "in"), c(5, 2, 3, 4, 1, 6, 7))

  expect_true(is_tree(g, mode = "in"))
  expect_equal(ignore_attr = TRUE, is_tree(g, mode = "in", details = TRUE), list(res = TRUE, root = V(g)[5]))

  expect_true(is_tree(g, mode = "all"))
  expect_equal(ignore_attr = TRUE, is_tree(g, mode = "all", details = TRUE), list(res = TRUE, root = V(g)[1]))

  expect_false(is_tree(g, mode = "out"))
  expect_false(is_tree(g, mode = "out", details = TRUE)$res)
})

test_that("is_tree works for directed out-trees", {
  g <- permute(make_tree(7, 2, mode = "out"), c(3, 2, 1, 4, 5, 6, 7))

  expect_true(is_tree(g, mode = "out"))
  expect_equal(ignore_attr = TRUE, is_tree(g, mode = "out", details = TRUE), list(res = TRUE, root = V(g)[3]))

  expect_true(is_tree(g, mode = "all"))
  expect_equal(ignore_attr = TRUE, is_tree(g, mode = "all", details = TRUE), list(res = TRUE, root = V(g)[1]))

  expect_false(is_tree(g, mode = "in"))
  expect_false(is_tree(g, mode = "in", details = TRUE)$res)
})

test_that("the null graph is not a tree", {
  expect_false(is_tree(make_empty_graph(0)))
})

test_that("a graph with a single vertex and no edges is tree", {
  expect_true(is_tree(make_empty_graph(1)))
})

test_that("is_forest takes edge directions into account correctly", {
  g <- make_graph(c(1,2, 2,3, 2,4, 5,4), n = 6, directed = TRUE)

  expect_true(is_forest(g, mode = "all"))
  expect_false(is_forest(g, mode = "out"))
  expect_false(is_forest(g, mode = "in"))
})

test_that("the null graph is a forest", {
  expect_true(is_forest(make_empty_graph(0)))
})

test_that("a graph with a single vertex and no edges is a forest", {
  expect_true(is_forest(make_empty_graph(1)))
})

test_that("to_prufer and make_from_prufer works for trees", {
  g <- make_tree(13, 3, mode = "undirected")
  seq <- to_prufer(g)
  g2 <- make_from_prufer(seq)
  expect_true(isomorphic(g, g2))

  g <- make_tree(13, 3, mode = "out")
  seq <- to_prufer(g)
  g2 <- make_from_prufer(seq)
  g3 <- as.undirected(g)
  expect_true(isomorphic(g2, g3))

  g <- make_tree(13, 3, mode = "in")
  seq <- to_prufer(g)
  g2 <- make_from_prufer(seq)
  g3 <- as.undirected(g)
  expect_true(isomorphic(g2, g3))
})

test_that("make_(from_prufer(...)) works", {
  g <- make_tree(13, 3, mode = "undirected")
  seq <- to_prufer(g)
  g2 <- make_(from_prufer(seq))
  expect_true(isomorphic(g, g2))
})

test_that("to_prufer prints an error for non-trees", {
  expect_error(to_prufer(make_graph("zachary")), "must be a tree")
})

test_that("sample_tree works", {
  g <- sample_tree(100)
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(99))
  expect_that(vcount(g), equals(100))
  expect_true(is_tree(g))

  g <- sample_tree(50, directed = T)
  expect_true(is_directed(g))
  expect_that(ecount(g), equals(49))
  expect_that(vcount(g), equals(50))
  expect_true(is_tree(g))

  g <- sample_tree(200, method = "prufer")
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(199))
  expect_that(vcount(g), equals(200))
  expect_true(is_tree(g))

  g <- sample_tree(200, method = "lerw")
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(199))
  expect_that(vcount(g), equals(200))
  expect_true(is_tree(g))
})

test_that("sample_(tree(...)) works", {
  g <- sample_(tree(200, method = "prufer"))
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(199))
  expect_that(vcount(g), equals(200))
  expect_true(is_tree(g))

  g2 <- sample_(tree(200, method = "prufer"))
  expect_false(is_directed(g2))
  expect_that(ecount(g2), equals(199))
  expect_that(vcount(g2), equals(200))
  expect_true(is_tree(g2))
  expect_false(identical_graphs(g, g2))
})

test_that("sample_tree yields a singleton graph for n=1", {
  g <- sample_tree(1)
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(0))
  expect_that(vcount(g), equals(1))
  expect_true(is_tree(g))
})

test_that("sample_tree yields a null graph for n=0", {
  g <- sample_tree(0)
  expect_false(is_directed(g))
  expect_that(ecount(g), equals(0))
  expect_that(vcount(g), equals(0))
  expect_false(is_tree(g)) # edge case, the null graph is not a tree even though it was generated by sample_tree()
})

test_that("sample_tree throws an error for the Prufer method with directed graphs", {
  expect_error(sample_tree(10, method = "prufer", directed = T), "nvalid value")
})

test_that("sample_spanning_tree works for connected graphs", {
  g <- make_full_graph(8)

  edges <- sample_spanning_tree(g)
  expect_that(length(edges), equals(7))

  sg <- subgraph.edges(g, edges)
  expect_that(vcount(sg), equals(8))
  expect_that(ecount(sg), equals(7))
  expect_that(sg, is_tree)
})

test_that("sample_spanning_tree works for disconnected graphs", {
  g <- make_full_graph(8) %du% make_full_graph(5)

  edges <- sample_spanning_tree(g, vid = 8)
  sg <- subgraph.edges(g, edges, delete.vertices = TRUE)
  expect_that(vcount(sg), equals(8))
  expect_that(ecount(sg), equals(7))
  expect_that(sg, is_tree)

  edges <- sample_spanning_tree(g, vid = 9)
  sg <- subgraph.edges(g, edges, delete.vertices = TRUE)
  expect_that(vcount(sg), equals(5))
  expect_that(ecount(sg), equals(4))
  expect_that(sg, is_tree)

  edges <- sample_spanning_tree(g)
  sg <- subgraph.edges(g, edges, delete.vertices = FALSE)
  expect_that(vcount(sg), equals(13))
  expect_that(ecount(sg), equals(11))
  expect_that(induced_subgraph(sg, 1:8), is_tree)
  expect_that(induced_subgraph(sg, 9:13), is_tree)
})
