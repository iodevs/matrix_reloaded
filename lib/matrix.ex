defmodule Matrix do
  @moduledoc """
  Provides a set of functions to work with matrices.
  """

  @type vector :: Vector.t()
  @type t :: [Vector.t()]
  @type dimension :: {pos_integer, pos_integer} | pos_integer
  @type index :: {non_neg_integer, non_neg_integer}
  @type element :: number | vector | Matrix.t()

  @doc """
  Create a new matrix of the specified size (number of rows and columns).
  Values `row` and `column` must be positive integer. Otherwise you get error
  message. All elements of the matrix are filled with the default value 0.
  This value can be changed. See example below.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ## Examples

      iex> Matrix.new(3)
      {:ok, [[0, 0, 0], [0, 0, 0], [0, 0, 0]]}

      iex> Matrix.new({2, 3}, -10)
      {:ok, [[-10, -10, -10], [-10, -10, -10]]}

  """
  @spec new(dimension, number) :: Result.t(String.t(), Matrix.t())
  def new(dimension, val \\ 0)

  def new({rows, cols}, val) when rows > 0 and cols > 0 do
    for(
      _r <- 1..rows,
      do: make_row(cols, val)
    )
    |> Result.ok()
  end

  def new(rows, val) when rows > 0 do
    for(
      _r <- 1..rows,
      do: make_row(rows, val)
    )
    |> Result.ok()
  end

  def new({_rows, _cols}, _val) do
    Result.error("It is not possible create the matrix with negative row or column!")
  end

  def new(_rows, _val) do
    Result.error("It is not possible create square matrix with negative row or column!")
  end

  @doc """
  Updates the matrix by given a submatrix. The position of submatrix inside matrix
  is given by index `{from_row, from_col}` and dimension of submatrix. Size of
  submatrix must be less than or equal to size of matrix. Otherwise you get error message.
  The values of indices start from 0 to (matrix row size - 1). Similarly for col size.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> Matrix.new(4) |> Result.and_then(&Matrix.update(&1, [[1,2],[3,4]], {1,2}))
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 1, 2],
          [0, 0, 3, 4],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update(Matrix.t(), element, index) :: Result.t(String.t(), Matrix.t())
  def update(matrix, submatrix, index) do
    matrix
    |> is_possible_insert_submatrix_on_position?(submatrix, index)
    |> Result.and_then(&is_possible_insert_submatrix_to_matrix?(&1, submatrix))
    |> Result.map(&make_update(&1, submatrix, index))
  end

  @doc """
  Updates the matrix by given a number. The position of element in matrix
  which you want to change is given by two non negative integers. These numbers
  must be from 0 to (matrix row size - 1). Similarly for col size.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> Matrix.new(3) |> Result.and_then(&Matrix.update_element(&1, -1, 1, 1))
      {:ok,
        [
          [0, 0, 0],
          [0, -1, 0],
          [0, 0, 0]
        ]
      }

  """
  @spec update_element(Matrix.t(), number, non_neg_integer, non_neg_integer) ::
          Result.t(String.t(), Matrix.t())
  def update_element(matrix, el, row, col) when is_number(el) do
    update(matrix, [[el]], {row, col})
  end

  @doc """
  Updates row in the matrix by given a row vector (list) of numbers. The row and
  columns which you want to change is given by tuple `{row, col}`. Both values
  are non negative integers.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> {:ok, mat} = Matrix.new(4)
      iex> Matrix.update_row(mat, [1, 2, 3], {3, 1})
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 1, 2, 3]
        ]
      }

  """
  @spec update_row(Matrix.t(), element, index) :: Result.t(String.t(), Matrix.t())
  def update_row(matrix, submatrix, index) do
    update(matrix, [submatrix], index)
  end

  @doc """
  Updates column in the matrix by given a column vector (list) of numbers.
  The column and rows which you want to change is given by tuple `{row, col}`.
  Both values are non negative integers.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> {:ok, mat} = Matrix.new(4)
      iex> Matrix.update_col(mat, [[1], [2], [3]], {0, 1})
      {:ok,
        [
          [0, 1, 0, 0],
          [0, 2, 0, 0],
          [0, 3, 0, 0],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update_col(Matrix.t(), element, index) :: Result.t(String.t(), Matrix.t())
  def update_col(matrix, submatrix, index) do
    update(matrix, submatrix, index)
  end

  @doc """
  Updates the matrix by given a submatrices. The positions (or locations) of these
  submatrices are given by list of indices. Index of the individual submatrices is
  tuple of two numbers. These two numbers are row and column of matrix where the
  submatrices will be located. All submatrices must have same size (dimension).

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> mat = Matrix.new(5)
      iex> sub_mat = Matrix.new(2,1)
      iex> positions = [{0,0}, {3, 3}]
      iex> Matrix.update_map(mat, sub_mat, positions)
      {:ok,
        [
          [1, 1, 0, 0, 0],
          [1, 1, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 1, 1],
          [0, 0, 0, 1, 1]
        ]
      }

  """
  @spec update_map(Matrix.t(), element, list(index)) :: Result.t(String.t(), Matrix.t())
  def update_map(matrix, submatrix, positions) do
    {row, col, check_size} = and_then2(matrix, submatrix, &check_size(&1, &2, positions))

    if check_size do
      Enum.reduce(positions, matrix, fn position, acc ->
        and_then2(
          acc,
          submatrix,
          &update(&1, &2, position)
        )
      end)
    else
      Result.error("Bad value of position {#{row}, #{col}}. Submatrix is out of matrix!")
    end
  end

  @doc """
  Creates a square diagonal matrix with the elements of vector on the main diagonal
  or on lower/upper bidiagonal if diagonal number `k` is k < 0 or 0 < k. This number
  must be integer.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:
      iex> Matrix.diag([1, 2, 3])
      {:ok,
        [
          [1, 0, 0],
          [0, 2, 0],
          [0, 0, 3]
        ]
      }
      iex> Matrix.diag([1, 2, 3], 1)
      {:ok,
        [
          [0, 1, 0, 0],
          [0, 0, 2, 0],
          [0, 0, 0, 3],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec diag(Vector.t(), integer()) :: Result.t(String.t(), Matrix.t())
  def diag(vector, k \\ 0)

  def diag(vector, k) when is_list(vector) and is_integer(k) and 0 <= k do
    len = length(vector)

    if k <= len do
      0..(len - 1)
      |> Enum.reduce(new(len + k), fn i, acc ->
        acc |> Result.and_then(&update_element(&1, Enum.at(vector, i), i, i + k))
      end)
    else
      Result.error("Length of upper bidiagonal must be less or equal to length of vector!")
    end
  end

  def diag(vector, k) when is_list(vector) and is_integer(k) and k < 0 do
    len = length(vector)

    if abs(k) <= len do
      0..(len - 1)
      |> Enum.reduce(new(len - k), fn i, acc ->
        acc |> Result.and_then(&update_element(&1, Enum.at(vector, i), i - k, i))
      end)
    else
      Result.error("Length of lower bidiagonal must be less or equal to length of vector!")
    end
  end

  @doc """
  Transpose of matrix.

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> mat = {:ok, [[1,2,3], [4,5,6], [7,8,9]]}
      iex> mat |> Result.and_then(&Matrix.transpose(&1))
      {:ok,
        [
          [1, 4, 7],
          [2, 5, 8],
          [3, 6, 9]
        ]
      }

  """
  @spec transpose(Matrix.t()) :: Result.t(String.t(), Matrix.t())
  def transpose(matrix) do
    matrix
    |> make_transpose()
    |> Result.ok()
  end

  @doc """
  Flip columns of matrix in the left-right direction (i.e. about a vertical axis).

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> mat = {:ok, [[1,2,3], [4,5,6], [7,8,9]]}
      iex> mat |> Result.and_then(&Matrix.flip_lr(&1))
      {:ok,
        [
          [3, 2, 1],
          [6, 5, 4],
          [9, 8, 7]
        ]
      }

  """
  @spec flip_lr(Matrix.t()) :: Result.t(String.t(), Matrix.t())
  def flip_lr(matrix) do
    matrix
    |> Enum.map(fn row -> Enum.reverse(row) end)
    |> Result.ok()
  end

  @doc """
  Flip rows of matrix in the up-down direction (i.e. about a horizontal axis).

  Returns result, it means either tuple of {:ok, matrix} or {:error, "msg"}.

  ##  Example:

      iex> mat = {:ok, [[1,2,3], [4,5,6], [7,8,9]]}
      iex> mat |> Result.and_then(&Matrix.flip_ud(&1))
      {:ok,
        [
          [7, 8, 9],
          [4, 5, 6],
          [1, 2, 3]
        ]
      }

  """
  @spec flip_ud(Matrix.t()) :: Result.t(String.t(), Matrix.t())
  def flip_ud(matrix) do
    matrix
    |> Enum.reverse()
    |> Result.ok()
  end

  @doc """
  The size (dimensions) of the matrix.

  Returns tuple of {row_size, col_size}.

  ## Example:

      iex> Matrix.new({3,4}) |> Result.and_then(&Matrix.size(&1))
      {3, 4}

  """
  @spec size(Matrix.t()) :: {pos_integer, pos_integer}
  def size(matrix), do: {length(matrix), length(List.first(matrix))}

  defp make_row(0, _val), do: []
  defp make_row(n, val), do: [val] ++ make_row(n - 1, val)

  defp is_possible_insert_submatrix_on_position?(
         matrix,
         submatrix,
         {from_row, from_col}
       ) do
    {row_size, col_size} = size(matrix)
    {row_size_sub, col_size_sub} = size(submatrix)

    calculated_row_size = from_row + row_size_sub
    calculated_col_size = from_col + col_size_sub

    if calculated_row_size <= row_size and calculated_col_size <= col_size do
      Result.ok(matrix)
    else
      Result.error(
        "On given position {#{from_row}, #{from_col}} you can not insert the submatrix size of {#{
          row_size_sub
        }, #{col_size_sub}}.A part of submatrix would be outside of matrix!"
      )
    end
  end

  defp is_possible_insert_submatrix_to_matrix?(
         matrix,
         submatrix
       ) do
    {row_size, col_size} = size(matrix)
    {row_size_sub, col_size_sub} = size(submatrix)

    if row_size_sub <= row_size and col_size_sub <= col_size do
      Result.ok(matrix)
    else
      Result.error("Size of submatrix is bigger than size of matrix!")
    end
  end

  defp make_update(matrix, submatrix, {from_row, from_col}) do
    {to_row, to_col} = size(submatrix)

    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      if i in from_row..(from_row + to_row - 1) do
        row
        |> Enum.with_index()
        |> Enum.map(fn {_col, j} ->
          if j in from_col..(from_col + to_col - 1) do
            submatrix |> Enum.at(i - from_row) |> Enum.at(j - from_col)
          else
            Enum.at(row, j)
          end
        end)
      else
        row
      end
    end)
  end

  defp make_transpose([[] | _]), do: []

  defp make_transpose(matrix) do
    [Enum.map(matrix, &hd/1) | make_transpose(Enum.map(matrix, &tl/1))]
  end

  defp and_then2({:ok, val1}, {:ok, val2}, f) when is_function(f, 2) do
    f.(val1, val2)
  end

  defp and_then2({:error, _} = result, _, _f), do: result
  defp and_then2(_, {:error, _} = result, _f), do: result

  defp check_size(matrix, submatrix, positions) do
    {rm, cm} = size(matrix)
    {rs, cs} = size(submatrix)

    Enum.reduce_while(
      positions,
      {rs, cs, true},
      fn {row_pos, col_pos}, acc ->
        if rs + row_pos <= rm and cs + col_pos <= cm do
          {:cont, acc}
        else
          {:halt, {row_pos, col_pos, false}}
        end
      end
    )
  end
end
