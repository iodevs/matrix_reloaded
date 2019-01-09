# MatrixReloaded
[![Build Status](https://semaphoreci.com/api/v1/s-m-i-t-a/matrix_reloaded/branches/master/badge.svg)](https://semaphoreci.com/s-m-i-t-a/matrix_reloaded)


This a library is focusing only on updating, rearranging, getting/dropping
row/column of a matrix. Also contains a few matrix operations like addition,
subtraction or multiplication. Anyway if you need make fast operations on
matrices, please use [Matrex](https://hexdocs.pm/matrex/Matrex.html) library.

Each matrix is represented as a "list of lists" and most functions return
[Result](https://hexdocs.pm/result/api-reference.html). It means either tuple
of `{:ok, element}` or `{:error, "msg"}` where `element` is type,
(see module Matrix).

Numbering of row and column of matrix starts from `0` and goes to `m - 1`
and `n - 1` where `{m, n}` is dimension (size) of matrix. Similarly for
a row or column vector.

In case of need, if you want to save your matrix to a file you can use package [CSVlixir](https://hexdocs.pm/csvlixir/api-reference.html) and then call function

```elixir
def save_csv(matrix, file_name \\ "matrix.csv") do
  file_name
  |> File.open([:write], fn file ->
    matrix
    |> CSVLixir.write()
    |> Enum.each(&IO.write(file, &1))
  end)
end
```

For example, you can choose where to save your matrix (in our case it's a `tmp` directory)
```elixir
MatrixReloaded.Matrix.new(3, 1)
|> Result.and_then(&MatrixReloaded.Matrix.save_csv(&1, "/tmp/matrix.csv"))
# {:ok, :ok}
```


  ## Examples:
```elixir
iex> alias MatrixReloaded.Matrix

iex> up = Matrix.diag([2, 2, 2], 1)
iex> down = Matrix.diag([2, 2, 2], -1)
iex> diag = Matrix.diag([3, 3, 3, 3])
iex> band_mat = Result.and_then_x([up, down], &Matrix.add(&1, &2))
iex> band_mat = Result.and_then_x([band_mat, diag], &Matrix.add(&1, &2))
{:ok,
  [
    [3, 2, 0, 0],
    [2, 3, 2, 0],
    [0, 2, 3, 2],
    [0, 0, 2, 3]
  ]
}

iex> ones = Matrix.new(2, 1)
iex> mat = Result.and_then_x([band_mat, ones], &Matrix.update(&1, &2, {1, 1}))
{:ok,
  [
    [3, 2, 0, 0],
    [2, 1, 1, 0],
    [0, 1, 1, 2],
    [0, 0, 2, 3]
  ]
}

iex> mat |> Result.and_then(&Matrix.get_row(&1, 4))
iex>
{:error, "You can not get row from the matrix. The row number 4 is outside of matrix!"}

iex> mat |> Result.and_then(&Matrix.get_row(&1, 3))
iex>
{:ok, [3, 2, 0, 0]}

iex(4)> mat |> Result.and_then(&Matrix.drop_col(&1, 3))
{:ok,
  [
    [3, 2, 0],
    [2, 3, 2],
    [0, 2, 3],
    [0, 0, 2]
  ]
}
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `matrix_reloaded` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:matrix_reloaded, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/matrix_reloaded](https://hexdocs.pm/matrix_reloaded).


## License
[![MIT](https://img.shields.io/packagist/l/doctrine/orm.svg)](LICENSE)
