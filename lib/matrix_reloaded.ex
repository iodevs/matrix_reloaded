defmodule MatrixReloaded do
  @moduledoc """
  Documentation for Matrix Reloaded library.

  This a library is focusing only on updating, rearranging, getting/dropping
  row/column of a matrix. Also contains a few matrix operations like addition,
  subtraction or multiplication. Anyway if you need make fast operations on
  matrices, please use [Matrex](https://hexdocs.pm/matrex/Matrex.html) library.

  Each matrix is represented as a "list of lists" and most functions return
  [Result](https://hexdocs.pm/result/api-reference.html). It means either tuple
  of `{:ok, element}` or `{:error, "msg"}` where `element` is type,
  (see module [Matrix](https://hexdocs.pm/matrix_reloaded/MatrixReloaded.Matrix.html#t:element/0)).

  ## Examples:

      iex> up = MatrixReloaded.Matrix.diag([2, 2, 2], 1)
      iex> down = MatrixReloaded.Matrix.diag([2, 2, 2], -1)
      iex> diag = MatrixReloaded.Matrix.diag([3, 3, 3, 3])
      iex> band_mat = Result.and_then_x([up, down], &MatrixReloaded.Matrix.add(&1, &2))
      iex> band_mat = Result.and_then_x([band_mat, diag], &MatrixReloaded.Matrix.add(&1, &2))
      {:ok,
        [
          [3, 2, 0, 0],
          [2, 3, 2, 0],
          [0, 2, 3, 2],
          [0, 0, 2, 3]
        ]
      }

      iex> ones = MatrixReloaded.Matrix.new(2, 1)
      iex> mat = Result.and_then_x([band_mat, ones], &MatrixReloaded.Matrix.update(&1, &2, {1, 1}))
      {:ok,
        [
          [3, 2, 0, 0],
          [2, 1, 1, 0],
          [0, 1, 1, 2],
          [0, 0, 2, 3]
        ]
      }

      iex> mat |> Result.and_then(&MatrixReloaded.Matrix.get_row(&1, 4))
      iex>
      {:error, "You can not get row from the matrix. The row number 4 is outside of matrix!"}

      iex> mat |> Result.and_then(&MatrixReloaded.Matrix.get_row(&1, 3))
      iex>
      {:ok, [3, 2, 0, 0]}

      iex(4)> mat |> Result.and_then(&MatrixReloaded.Matrix.drop_col(&1, 3))
      {:ok,
        [
          [3, 2, 0],
          [2, 3, 2],
          [0, 2, 3],
          [0, 0, 2]
        ]
      }

  """
end
