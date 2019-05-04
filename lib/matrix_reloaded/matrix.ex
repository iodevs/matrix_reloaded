defmodule MatrixReloaded.Matrix do
  @moduledoc """
  Provides a set of functions to work with matrices.

  Don't forget, numbering of row and column starts from `0` and goes
  to `m - 1` and `n - 1` where `{m, n}` is dimension (size) of matrix.
  """

  alias MatrixReloaded.Vector

  @type t :: [Vector.t()]
  @type dimension :: {pos_integer, pos_integer} | pos_integer
  @type index :: {non_neg_integer, non_neg_integer}
  @type submatrix :: number | Vector.t() | t()

  @doc """
  Creates a new matrix of the specified size. In case of positive number you get
  a squared matrix, for tuple `{m, n}` you get a rectangular matrix. For negative
  values you get an error message. All elements of the matrix are filled with the
  default value 0. This value can be changed.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Matrix.new(3)
      {:ok, [[0, 0, 0], [0, 0, 0], [0, 0, 0]]}

      iex> MatrixReloaded.Matrix.new({2, 3}, -10)
      {:ok, [[-10, -10, -10], [-10, -10, -10]]}

  """
  @spec new(dimension, number) :: Result.t(String.t(), t())
  def new(dimension, val \\ 0)

  def new(dim, val) when is_tuple(dim) do
    dim
    |> is_dimension_ok?()
    |> Result.map(fn {rows, cols} ->
      for(
        _r <- 1..rows,
        do: make_row(cols, val)
      )
    end)
  end

  def new(dim, val) do
    dim
    |> is_dimension_ok?()
    |> Result.map(fn row ->
      for(
        _r <- 1..row,
        do: make_row(row, val)
      )
    end)
  end

  @doc """
  Summation of two matrices. Sizes (dimensions) of both matrices must be same.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> mat1 = {:ok, [[1, 2, 3], [4, 5, 6], [7, 8, 9]]}
      iex> mat2 = MatrixReloaded.Matrix.new(3,1)
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.add(&1, &2))
      {:ok,
        [
          [2, 3, 4],
          [5, 6, 7],
          [8, 9, 10]
        ]
      }

  """
  @spec add(t(), t()) :: Result.t(String.t(), t())
  def add(matrix1, matrix2) do
    {rs1, cs1} = size(matrix1)
    {rs2, cs2} = size(matrix2)

    if rs1 == rs2 and cs1 == cs2 do
      matrix1
      |> Enum.zip(matrix2)
      |> Enum.map(fn {row1, row2} ->
        Vector.add(row1, row2)
      end)
      |> Result.product()
    else
      Result.error("Sizes (dimensions) of both matrices must be same!")
    end
  end

  @doc """
  Subtraction of two matrices. Sizes (dimensions) of both matrices must be same.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> mat1 = {:ok, [[1, 2, 3], [4, 5, 6], [7, 8, 9]]}
      iex> mat2 = MatrixReloaded.Matrix.new(3,1)
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.sub(&1, &2))
      {:ok,
        [
          [0, 1, 2],
          [3, 4, 5],
          [6, 7, 8]
        ]
      }

  """
  @spec sub(t(), t()) :: Result.t(String.t(), t())
  def sub(matrix1, matrix2) do
    {rs1, cs1} = size(matrix1)
    {rs2, cs2} = size(matrix2)

    if rs1 == rs2 and cs1 == cs2 do
      matrix1
      |> Enum.zip(matrix2)
      |> Enum.map(fn {row1, row2} ->
        Vector.sub(row1, row2)
      end)
      |> Result.product()
    else
      Result.error("Sizes (dimensions) of both matrices must be same!")
    end
  end

  @doc """
  Product of two matrices. If matrix `A` has a size `n × p` and matrix `B` has
  a size `p × m` then their matrix product `A*B` is matrix of size `n × m`.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> mat1 = {:ok, [[1, 2], [3, 4], [5, 6], [7, 8]]}
      iex> mat2 = {:ok, [[1, 2 ,3], [4, 5, 6]]}
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.product(&1, &2))
      {:ok,
        [
          [9, 12, 15],
          [19, 26, 33],
          [29, 40, 51],
          [39, 54, 69]
        ]
      }

  """
  @spec product(t(), t()) :: Result.t(String.t(), t())
  def product(matrix1, matrix2) do
    {_rs1, cs1} = size(matrix1)
    {rs2, _cs2} = size(matrix2)

    if cs1 == rs2 do
      matrix1
      |> Enum.map(fn row1 ->
        matrix2
        |> transpose()
        |> Enum.map(fn row2 -> Vector.dot(row1, row2) end)
      end)
      |> Enum.map(&Result.product(&1))
      |> Result.product()
    else
      Result.error("Column size of first matrix must be same as row size of second matrix!")
    end
  end

  @doc """
  Schur product (or the Hadamard product) of two matrices. It produces another
  matrix where each element `i, j` is the product of elements `i, j` of the
  original two matrices. Sizes (dimensions) of both matrices must be same.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> mat1 = {:ok, [[1, 2, 3], [5, 6, 7]]}
      iex> mat2 = {:ok, [[1, 2 ,3], [4, 5, 6]]}
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.schur_product(&1, &2))
      {:ok,
        [
          [1, 4, 9],
          [20, 30, 42]
        ]
      }

  """
  @spec schur_product(t(), t()) :: Result.t(String.t(), t())
  def schur_product(matrix1, matrix2) do
    {rs1, cs1} = size(matrix1)
    {rs2, cs2} = size(matrix2)

    if rs1 == rs2 and cs1 == cs2 do
      matrix1
      |> Enum.zip(matrix2)
      |> Enum.map(fn {row1, row2} -> Vector.inner_product(row1, row2) end)
      |> Result.product()
    else
      Result.error(
        "Dimension of matrix {#{rs1}, #{cs1}} is not same as dimension of matrix {#{rs2}, #{cs2}}!"
      )
    end
  end

  @doc """
  Updates the matrix by given a submatrix. The position of submatrix inside
  matrix is given by index `{row_num, col_num}` and dimension of submatrix.
  Size of submatrix must be less than or equal to size of matrix. Otherwise
  you get an error message. The values of indices start from `0` to `matrix row size - 1`.
  Similarly for `col` size.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = MatrixReloaded.Matrix.new(4)
      iex> mat |> Result.and_then(&MatrixReloaded.Matrix.update(&1, [[1,2],[3,4]], {1,2}))
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 1, 2],
          [0, 0, 3, 4],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update(t(), submatrix, index) :: Result.t(String.t(), t())
  def update(matrix, submatrix, index) do
    matrix
    |> is_index_ok?(index)
    |> Result.and_then(
      &is_submatrix_smaller_than_matrix?(&1, size(matrix), size(submatrix), :update)
    )
    |> Result.and_then(&is_submatrix_in_matrix?(&1, size(matrix), size(submatrix), index))
    |> Result.map(&make_update(&1, submatrix, index))
  end

  @doc """
  Updates the matrix by given a number. The position of element in matrix
  which you want to change is given by tuple `{row_num, col_num}`.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = MatrixReloaded.Matrix.new(3)
      iex> mat |> Result.and_then(&MatrixReloaded.Matrix.update_element(&1, -1, {1, 1}))
      {:ok,
        [
          [0, 0, 0],
          [0, -1, 0],
          [0, 0, 0]
        ]
      }

  """
  @spec update_element(t(), number, index) :: Result.t(String.t(), t())
  def update_element(matrix, el, index) when is_number(el) do
    matrix
    |> is_index_ok?(index)
    |> Result.and_then(&is_element_in_matrix?(&1, size(matrix), index))
    |> Result.map(&make_update(&1, [[el]], index))
  end

  @doc """
  Updates row in the matrix by given a row vector (list) of numbers. The row which
  you want to change is given by tuple `{row_num, col_num}`. Both values are non
  negative integers.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:
      iex> {:ok, mat} = MatrixReloaded.Matrix.new(4)
      iex> MatrixReloaded.Matrix.update_row(mat, [1, 2, 3], {3, 1})
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 1, 2, 3]
        ]
      }

  """
  @spec update_row(t(), Vector.t(), index) :: Result.t(String.t(), t())
  def update_row(matrix, row, index) do
    matrix
    |> is_index_ok?(index)
    |> Result.and_then(&is_row_ok?(&1, row))
    |> Result.and_then(&is_row_size_smaller_than_rows_of_matrix?(&1, size(matrix), length(row)))
    |> Result.and_then(&is_row_in_matrix?(&1, size(matrix), length(row), index))
    |> Result.map(&make_update(&1, [row], index))
  end

  @doc """
  Updates column in the matrix by given a column vector. The column which you
  want to change is given by tuple `{row_num, col_num}`. Both values are non
  negative integers.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> {:ok, mat} = MatrixReloaded.Matrix.new(4)
      iex> MatrixReloaded.Matrix.update_col(mat, [[1], [2], [3]], {0, 1})
      {:ok,
        [
          [0, 1, 0, 0],
          [0, 2, 0, 0],
          [0, 3, 0, 0],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec update_col(t(), Vector.column(), index) :: Result.t(String.t(), t())
  def update_col(matrix, [hd | _] = submatrix, index)
      when is_list(submatrix) and length(hd) == 1 do
    update(matrix, submatrix, index)
  end

  @doc """
  Updates the matrix by given a submatrices. The positions (or locations) of these
  submatrices are given by list of indices. Index of the individual submatrices is
  tuple of two numbers. These two numbers are number row and number column of matrix
  where the submatrices will be located. All submatrices must have same size (dimension).

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = MatrixReloaded.Matrix.new(5)
      iex> sub_mat = MatrixReloaded.Matrix.new(2,1)
      iex> positions = [{0,0}, {3, 3}]
      iex> [mat, sub_mat] |> Result.and_then_x(&MatrixReloaded.Matrix.update_map(&1, &2, positions))
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
  @spec update_map(t(), submatrix, list(index)) :: Result.t(String.t(), t())
  def update_map(matrix, submatrix, position_indices) do
    Enum.reduce(position_indices, {:ok, matrix}, fn position, acc ->
      Result.and_then(acc, &update(&1, submatrix, position))
    end)
  end

  @doc """
  Gets a submatrix from the matrix. By index you can select a submatrix. Dimension of
  submatrix is given by positive number (result then will be a square matrix) or tuple
  of two positive numbers (you get then a rectangular matrix).

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_submatrix(mat, {1, 2}, 2)
      {:ok,
        [
          [1, 2],
          [3, 4]
        ]
      }

      iex> mat = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 2, 3], [0, 4, 5, 6]]
      iex> MatrixReloaded.Matrix.get_submatrix(mat, {2, 1}, {3, 3})
      {:ok,
        [
          [1, 2, 3],
          [4, 5, 6]
        ]
      }

  """
  @spec get_submatrix(t(), index, dimension) :: Result.t(String.t(), t())
  def get_submatrix(matrix, index, dimension) do
    dim_sub = dimension_of_submatrix(index, dimension)

    matrix
    |> is_index_ok?(index)
    |> Result.and_then(&is_submatrix_smaller_than_matrix?(&1, size(matrix), dim_sub, :get))
    |> Result.and_then(&is_submatrix_in_matrix?(&1, size(matrix), index, dim_sub, :get))
    |> Result.map(&make_get_submatrix(&1, index, dim_sub))
  end

  @doc """
  Gets an element from the matrix. By index you can select an element.

  Returns result, it means either tuple of `{:ok, number}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_element(mat, {2, 2})
      {:ok, 3}

  """
  @spec get_element(t(), index) :: Result.t(String.t(), number)
  def get_element(matrix, index) when is_tuple(index) do
    dim_sub = dimension_of_submatrix(index, 1)

    matrix
    |> is_element_in_matrix?(size(matrix), index, :get)
    |> Result.map(&make_get_submatrix(&1, index, dim_sub))
    |> Result.map(fn el -> el |> hd |> hd end)
  end

  @doc """
  Gets a whole row from the matrix. By row number you can select the row which
  you want.

  Returns result, it means either tuple of `{:ok, number}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_row(mat, 1)
      {:ok, [0, 0, 1, 2]}

  """
  @spec get_row(t(), non_neg_integer) :: Result.t(String.t(), Vector.t())
  def get_row(matrix, row_num) do
    {rs, cs} = size(matrix)

    matrix
    |> is_non_neg_integer?(row_num)
    |> Result.and_then(&is_row_num_at_matrix?(&1, {rs, cs}, row_num))
    |> Result.map(&make_get_submatrix(&1, {row_num, 0}, {row_num, cs}))
    |> Result.map(&hd(&1))
  end

  @doc """
  Gets a part row from the matrix. By index and positive number you can select
  the row and elements which you want.

  Returns result, it means either tuple of `{:ok, number}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_row(mat, {2, 1}, 2)
      {:ok, [0, 3]}

  """
  @spec get_row(t(), index, non_neg_integer) :: Result.t(String.t(), Vector.t())
  def get_row(matrix, {row_num, _} = index, num_of_el) do
    {rs, cs} = size(matrix)

    matrix
    |> is_index_ok?(index)
    |> Result.and_then(&is_positive_integer?(&1, num_of_el))
    |> Result.and_then(&is_row_num_at_matrix?(&1, {rs, cs}, row_num))
    |> Result.map(&make_get_submatrix(&1, index, {row_num, num_of_el}))
    |> Result.map(&hd(&1))
  end

  @doc """
  Gets a whole column from the matrix. By column number you can select the column
  which you want.

  Returns result, it means either tuple of `{:ok, number}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_col(mat, 3)
      {:ok, [[0], [2], [4], [0]]}

  """
  @spec get_col(t(), non_neg_integer) :: Result.t(String.t(), Vector.column())
  def get_col(matrix, col_num) do
    {rs, cs} = size(matrix)

    matrix
    |> is_non_neg_integer?(col_num)
    |> Result.map(&transpose/1)
    |> Result.and_then(&is_row_num_at_matrix?(&1, {rs, cs}, col_num, :column))
    |> Result.map(&make_get_submatrix(&1, {col_num, 0}, {col_num, cs}))
    |> Result.map(&hd(&1))
    |> Result.map(&Vector.transpose(&1))
  end

  @doc """
  Gets a part column from the matrix. By index and positive number you can select
  the column and elements which you want.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.get_col(mat, {1, 2}, 2)
      {:ok, [[1], [3]]}

  """
  @spec get_col(t(), index, non_neg_integer) :: Result.t(String.t(), Vector.column())
  def get_col(matrix, {row_num, col_num} = index, num_of_el) do
    {rs, cs} = size(matrix)

    matrix
    |> is_index_ok?(index)
    |> Result.and_then(&is_positive_integer?(&1, num_of_el))
    |> Result.map(&transpose/1)
    |> Result.and_then(&is_row_num_at_matrix?(&1, {cs, rs}, col_num, :column))
    |> Result.map(&make_get_submatrix(&1, {col_num, row_num}, {col_num, num_of_el}))
    |> Result.map(&hd(&1))
    |> Result.map(&Vector.transpose(&1))
  end

  @doc """
  Creates a square diagonal matrix with the elements of vector on the main diagonal
  or on lower/upper bidiagonal if diagonal number `k` is `k < 0` or `0 < k`.
  This number `k` must be integer.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:
      iex> MatrixReloaded.Matrix.diag([1, 2, 3])
      {:ok,
        [
          [1, 0, 0],
          [0, 2, 0],
          [0, 0, 3]
        ]
      }
      iex> MatrixReloaded.Matrix.diag([1, 2, 3], 1)
      {:ok,
        [
          [0, 1, 0, 0],
          [0, 0, 2, 0],
          [0, 0, 0, 3],
          [0, 0, 0, 0]
        ]
      }

  """
  @spec diag(Vector.t(), integer()) :: Result.t(String.t(), t())
  def diag(vector, k \\ 0)

  def diag(vector, k) when is_list(vector) and is_integer(k) and 0 <= k do
    len = length(vector)

    if k <= len do
      0..(len - 1)
      |> Enum.reduce(new(len + k), fn i, acc ->
        acc |> Result.and_then(&update_element(&1, Enum.at(vector, i), {i, i + k}))
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
        acc |> Result.and_then(&update_element(&1, Enum.at(vector, i), {i - k, i}))
      end)
    else
      Result.error("Length of lower bidiagonal must be less or equal to length of vector!")
    end
  end

  @doc """
  Transpose of matrix.

  ##  Example:

      iex> mat = [[1,2,3], [4,5,6], [7,8,9]]
      iex> MatrixReloaded.Matrix.transpose(mat)
      [
        [1, 4, 7],
        [2, 5, 8],
        [3, 6, 9]
      ]

  """
  @spec transpose(t()) :: t()
  def transpose(matrix) do
    matrix
    |> make_transpose()
  end

  @doc """
  Flip columns of matrix in the left-right direction (i.e. about a vertical axis).

  ##  Example:

      iex> mat = [[1,2,3], [4,5,6], [7,8,9]]
      iex> MatrixReloaded.Matrix.flip_lr(mat)
      [
        [3, 2, 1],
        [6, 5, 4],
        [9, 8, 7]
      ]

  """
  @spec flip_lr(t()) :: t()
  def flip_lr(matrix) do
    matrix
    |> Enum.map(fn row -> Enum.reverse(row) end)
  end

  @doc """
  Flip rows of matrix in the up-down direction (i.e. about a horizontal axis).

  ##  Example:

      iex> mat = [[1,2,3], [4,5,6], [7,8,9]]
      iex> MatrixReloaded.Matrix.flip_ud(mat)
      [
        [7, 8, 9],
        [4, 5, 6],
        [1, 2, 3]
      ]

  """
  @spec flip_ud(t()) :: t()
  def flip_ud(matrix) do
    matrix
    |> Enum.reverse()
  end

  @doc """
  Drops the row or list of rows from the matrix. The row number (or row numbers)
  must be positive integer.

  Returns matrix.

  ##  Example:
      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.drop_row(mat, 2)
      {:ok,
        [
          [0, 0, 0, 0],
          [0, 0, 1, 2],
          [0, 0, 0, 0]
        ]
      }

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.drop_row(mat, [0, 3])
      {:ok,
        [
          [0, 0, 1, 2],
          [0, 0, 3, 4]
        ]
      }

  """
  @spec drop_row(t(), non_neg_integer | [non_neg_integer]) :: Result.t(String.t(), t())
  def drop_row(matrix, rows) when is_list(rows) do
    matrix
    |> is_all_row_numbers_ok?(rows)
    |> Result.and_then(&make_drop_rows(&1, rows))
  end

  def drop_row(matrix, row) do
    matrix
    |> is_non_neg_integer?(row)
    |> Result.and_then(&make_drop_row(&1, row))
  end

  @doc """
  Drops the column or list of columns from the matrix. The column number
  (or column numbers) must be positive integer.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:
      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.drop_col(mat, 2)
      {:ok,
        [
          [0, 0, 0],
          [0, 0, 2],
          [0, 0, 4],
          [0, 0, 0]
        ]
      }

      iex> mat = [[0, 0, 0, 0], [0, 0, 1, 2], [0, 0, 3, 4], [0, 0, 0, 0]]
      iex> MatrixReloaded.Matrix.drop_col(mat, [0, 1])
      {:ok,
        [
          [0, 0],
          [1, 2],
          [3, 4],
          [0, 0]
        ]
      }

  """
  @spec drop_col(t(), non_neg_integer | [non_neg_integer]) :: Result.t(String.t(), t())
  def drop_col(matrix, cols) when is_list(cols) do
    matrix
    |> transpose()
    |> is_all_row_numbers_ok?(cols)
    |> Result.and_then(&make_drop_rows(&1, cols, :column))
    |> Result.map(&transpose/1)
  end

  def drop_col(matrix, col) do
    matrix
    |> transpose()
    |> is_non_neg_integer?(col)
    |> Result.and_then(&make_drop_row(&1, col, :column))
    |> Result.map(&transpose/1)
  end

  @doc """
  Concatenate matrices horizontally. Both matrices must have same a row dimension.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:
      iex> mat1 = MatrixReloaded.Matrix.diag([1, 1, 1])
      iex> mat2 = MatrixReloaded.Matrix.diag([2, 2, 2])
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.concat_row(&1, &2))
      {:ok,
        [
          [1, 0, 0, 2, 0, 0],
          [0, 1, 0, 0, 2, 0],
          [0, 0, 1, 0, 0, 2]
        ]
      }

  """
  @spec concat_row(t(), t()) :: Result.t(String.t(), t())
  def concat_row(matrix1, matrix2) do
    {rs1, _cs1} = size(matrix1)
    {rs2, _cs2} = size(matrix2)

    if rs1 == rs2 do
      matrix1
      |> Enum.zip(matrix2)
      |> Enum.map(fn {r1, r2} -> Enum.concat(r1, r2) end)
      |> Result.ok()
    else
      Result.error("Matrices have different row dimensions. Must be same!")
    end
  end

  @doc """
  Concatenate matrices vertically. Both matrices must have same a column dimension.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ##  Example:
      iex> mat1 = MatrixReloaded.Matrix.diag([1, 1, 1])
      iex> mat2 = MatrixReloaded.Matrix.diag([2, 2, 2])
      iex> Result.and_then_x([mat1, mat2], &MatrixReloaded.Matrix.concat_col(&1, &2))
      {:ok,
        [
          [1, 0, 0],
          [0, 1, 0],
          [0, 0, 1],
          [2, 0, 0],
          [0, 2, 0],
          [0, 0, 2]
        ]
      }

  """
  @spec concat_col(t(), t()) :: Result.t(String.t(), t())
  def concat_col(matrix1, matrix2) do
    {_rs1, cs1} = size(matrix1)
    {_rs2, cs2} = size(matrix2)

    if cs1 == cs2 do
      matrix1
      |> Enum.concat(matrix2)
      |> Result.ok()
    else
      Result.error("Matrices have different column dimensions. Must be same!")
    end
  end

  @doc """
  Reshape vector or matrix. The `row` and `col` numbers must be positive number.
  By the `row` or `col` number you can change shape of matrix, respectively create
  new from vector.

  Returns result, it means either tuple of `{:ok, vector | matrix}` or `{:error, "msg"}`.

  ## Example:
      iex> 1..10 |> Enum.to_list |> MatrixReloaded.Matrix.reshape(5, 2)
      {:ok,
        [
          [1, 2],
          [3, 4],
          [5, 6],
          [7, 8],
          [9, 10]
        ]
      }

      iex> MatrixReloaded.Matrix.new({3,4}) |> Result.map(&MatrixReloaded.Matrix.reshape(&1, 2, 6))
      {:ok,
        [
          [0, 0, 0, 0, 0, 0,],
          [0, 0, 0, 0, 0, 0,]
        ]
      }

  """
  @spec reshape(Vector.t() | t(), pos_integer(), pos_integer()) ::
          Result.t(String.t(), Vector.t()) | Result.t(String.t(), t())
  def reshape([el | _] = vector, row, col)
      when is_list(vector) and is_number(el) and
             is_integer(row) and row > 0 and is_integer(col) and col == 1 do
    vector
    |> transpose()
  end

  def reshape([el | _] = vector, row, col)
      when is_list(vector) and is_number(el) and
             is_integer(row) and row == 1 and is_integer(col) and col > 0 do
    vector
  end

  def reshape([el | _] = vector, row, col)
      when is_list(vector) and is_number(el) and
             is_integer(row) and row > 0 and is_integer(col) and col > 0 do
    vector
    |> is_reshapeable?(row, col)
    |> Result.map(&Enum.chunk_every(&1, col))
  end

  def reshape([r | _] = matrix, row, col)
      when is_list(matrix) and is_list(r) and
             is_integer(row) and row == 1 and is_integer(col) and col > 0 do
    matrix
    |> is_reshapeable?(row, col)
    |> Result.and_then(&List.flatten(&1))
  end

  def reshape([r | _] = matrix, row, col)
      when is_list(matrix) and is_list(r) and
             is_integer(row) and row > 0 and is_integer(col) and col > 0 do
    matrix
    |> is_reshapeable?(row, col)
    |> Result.map(&List.flatten(&1))
    |> Result.and_then(&Enum.chunk_every(&1, col))
  end

  def reshape(_matrix, row, col) when row < 2 and col < 2 do
    Result.error("'row' and 'col' number must be positive integer number greater than 0!")
  end

  @doc """
  The size (dimensions) of the matrix.

  Returns tuple of {row_size, col_size}.

  ## Example:

      iex> MatrixReloaded.Matrix.new({3,4}) |> Result.map(&MatrixReloaded.Matrix.size(&1))
      {:ok, {3, 4}}

  """
  @spec size(t()) :: {pos_integer, pos_integer}
  def size(matrix), do: {length(matrix), length(List.first(matrix))}

  defp make_row(0, _val), do: []
  defp make_row(n, val), do: [val] ++ make_row(n - 1, val)

  defp make_update(matrix, submatrix, {from_row, from_col}) do
    {to_row, to_col} = size(submatrix)

    matrix
    |> Enum.with_index()
    |> Enum.map(fn {row, i} ->
      if i in from_row..(from_row + to_row - 1) do
        row
        |> Enum.with_index()
        |> Enum.map(fn {val, j} ->
          if j in from_col..(from_col + to_col - 1) do
            submatrix |> Enum.at(i - from_row) |> Enum.at(j - from_col)
          else
            val
          end
        end)
      else
        row
      end
    end)
  end

  defp make_get_submatrix(matrix, {from_row, from_col}, {to_row, to_col}) do
    matrix
    |> Enum.with_index()
    |> Enum.filter(fn {_row, i} ->
      i in from_row..(from_row + to_row - 1)
    end)
    |> Enum.map(fn {row, _i} ->
      row
      |> Enum.with_index()
      |> Enum.filter(fn {_col, j} ->
        j in from_col..(from_col + to_col - 1)
      end)
      |> Enum.map(fn {val, _j} -> val end)
    end)
  end

  defp make_drop_rows(matrix, rows, vec \\ :row) do
    {row_size, col_size} = size(matrix)

    if length(rows) < row_size do
      row_help =
        0..(length(rows) - 1)
        |> Enum.to_list()

      rows
      |> Vector.sub(row_help)
      |> Result.and_then(
        &Enum.reduce(&1, {:ok, matrix}, fn r, acc ->
          acc |> Result.and_then(fn a -> drop_row(a, r) end)
        end)
      )
    else
      Result.error(
        "It is not possible drop all the #{Atom.to_string(vec)}s from matrix! Matrix has dimensions {#{
          row_size
        }, #{col_size}}."
      )
    end
  end

  defp make_drop_row(matrix, row, vec \\ "row") do
    {row_size, _col_size} = size(matrix)

    if row < row_size do
      matrix
      |> List.delete_at(row)
      |> Result.ok()
    else
      Result.error(
        "It is not possible drop the #{vec} #{row} from matrix! Numbering of #{vec}s begins from 0 to (matrix #{
          vec
        } size - 1)."
      )
    end
  end

  defp make_transpose([[] | _]), do: []

  defp make_transpose(matrix) do
    [Enum.map(matrix, &hd/1) | make_transpose(Enum.map(matrix, &tl/1))]
  end

  defp is_submatrix_smaller_than_matrix?(
         matrix,
         {rs_mat, cs_mat},
         {rs_sub, cs_sub},
         _method
       )
       when rs_sub < rs_mat and cs_sub < cs_mat do
    Result.ok(matrix)
  end

  defp is_submatrix_smaller_than_matrix?(
         _matrix,
         _size_mat,
         _size_sub,
         :update
       ) do
    Result.error(
      "You can not update the matrix. Size of submatrix is same or bigger than size of matrix!"
    )
  end

  defp is_submatrix_smaller_than_matrix?(
         _matrix,
         _size_mat,
         _size_sub,
         :get
       ) do
    Result.error(
      "You can not get the submatrix. Size of submatrix is same or bigger than size of matrix!"
    )
  end

  defp is_row_size_smaller_than_rows_of_matrix?(
         matrix,
         size_mat,
         size_row,
         method \\ :update
       )

  defp is_row_size_smaller_than_rows_of_matrix?(
         matrix,
         {_rs_mat, cs_mat},
         size_r,
         _method
       )
       when size_r <= cs_mat do
    Result.ok(matrix)
  end

  defp is_row_size_smaller_than_rows_of_matrix?(
         _matrix,
         _size_mat,
         _size_row,
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} the matrix. Size of row is bigger than row size of matrix!"
    )
  end

  defp is_element_in_matrix?(
         matrix,
         size_mat,
         index,
         method \\ :update
       )

  defp is_element_in_matrix?(
         matrix,
         {rs_mat, cs_mat},
         {from_row, from_col},
         _method
       )
       when from_row < rs_mat and from_col < cs_mat do
    Result.ok(matrix)
  end

  defp is_element_in_matrix?(
         _matrix,
         _size_mat,
         {from_row, from_col},
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} the matrix on given position {#{from_row}, #{
        from_col
      }}. The element is outside of matrix!"
    )
  end

  defp is_submatrix_in_matrix?(
         matrix,
         size_mat,
         size_sub,
         index,
         method \\ :update
       )

  defp is_submatrix_in_matrix?(
         matrix,
         {rs_mat, cs_mat},
         {to_row, to_col},
         {from_row, from_col},
         _method
       )
       when from_row + to_row - 1 < rs_mat and from_col + to_col - 1 < cs_mat do
    Result.ok(matrix)
  end

  defp is_submatrix_in_matrix?(
         _matrix,
         _size_mat,
         _size_sub,
         {from_row, from_col},
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} the matrix on given position {#{from_row}, #{
        from_col
      }}. The submatrix is outside of matrix!"
    )
  end

  defp is_row_in_matrix?(
         matrix,
         size_mat,
         size_row,
         index,
         method \\ :update
       )

  defp is_row_in_matrix?(
         matrix,
         {rs_mat, cs_mat},
         s_row,
         {from_row, from_col},
         _method
       )
       when from_row <= rs_mat and from_col + s_row <= cs_mat do
    Result.ok(matrix)
  end

  defp is_row_in_matrix?(
         _matrix,
         _size_mat,
         _size_row,
         {from_row, from_col},
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} row in the matrix on given position {#{from_row}, #{
        from_col
      }}. A part of row is outside of matrix!"
    )
  end

  defp is_row_num_at_matrix?(matrix, size_mat, row_num, vec \\ :row)

  defp is_row_num_at_matrix?(matrix, {rs_mat, _cs_mat}, row_num, _vec)
       when row_num < rs_mat do
    Result.ok(matrix)
  end

  defp is_row_num_at_matrix?(
         _matrix,
         _size_mat,
         row_num,
         vec
       ) do
    Result.error(
      "You can not get #{Atom.to_string(vec)} from the matrix. The #{Atom.to_string(vec)} number #{
        row_num
      } is outside of matrix!"
    )
  end

  defp dimension_of_submatrix({from_row, from_col}, {to_row, to_col} = dimension)
       when is_tuple(dimension) do
    {to_row - from_row + 1, to_col - from_col + 1}
  end

  defp dimension_of_submatrix(_index, dimension) do
    {dimension, dimension}
  end

  defp is_row_ok?(matrix, [hd | _] = row) when is_list(row) and is_number(hd) do
    Result.ok(matrix)
  end

  defp is_row_ok?(_matrix, _row) do
    Result.error("Input row (or column) vector must be only list of numbers!")
  end

  defp is_all_row_numbers_ok?(matrix, row_list, vec \\ :row) do
    is_all_ok? =
      row_list
      |> Enum.map(fn r -> 0 <= r end)
      |> Enum.find_index(fn r -> r == false end)

    if is_all_ok? == nil do
      Result.ok(matrix)
    else
      Result.error("List of #{Atom.to_string(vec)} numbers must be greater or equal to zero!")
    end
  end

  defp is_dimension_ok?({rows, cols} = tpl)
       when tuple_size(tpl) == 2 and is_integer(rows) and rows > 0 and is_integer(cols) and
              cols > 0 do
    Result.ok(tpl)
  end

  defp is_dimension_ok?({rows, cols}) do
    Result.error(
      "The size {#{rows}, #{cols}} of matrix must be in the form {m, n} where m, n are positive integers!"
    )
  end

  defp is_dimension_ok?(dim)
       when is_integer(dim) and 0 < dim do
    Result.ok(dim)
  end

  defp is_dimension_ok?(_dim) do
    Result.error("Dimension of squared matrix must be positive integer!")
  end

  defp is_index_ok?(matrix, ind)
       when is_tuple(ind) and tuple_size(ind) == 2 and is_integer(elem(ind, 0)) and
              0 <= elem(ind, 0) and is_integer(elem(ind, 1)) and 0 <= elem(ind, 1) do
    Result.ok(matrix)
  end

  defp is_index_ok?(_matrix, _index) do
    Result.error("The index must be in the form {m, n} where 0 <= m and 0 <= n !")
  end

  defp is_non_neg_integer?(matrix, num) when is_integer(num) and 0 <= num do
    Result.ok(matrix)
  end

  defp is_non_neg_integer?(_matrix, num) when is_number(num) do
    Result.error("The integer number must be greater or equal to zero!")
  end

  defp is_positive_integer?(matrix, num) when is_integer(num) and 0 < num do
    Result.ok(matrix)
  end

  defp is_positive_integer?(_matrix, num) when is_number(num) do
    Result.error("The integer number must be positive, i.e. n > 0 !")
  end

  defp is_reshapeable?([el | _] = vector, row, col)
       when is_list(vector) and is_number(el) and length(vector) == row * col do
    Result.ok(vector)
  end

  defp is_reshapeable?([el | _] = vector, _row, _col)
       when is_list(vector) and is_number(el) do
    Result.error(
      "It is not possible to reshape vector! The numbers of element of vector must be equal row * col."
    )
  end

  defp is_reshapeable?([r | _] = matrix, row, col)
       when is_list(matrix) and is_list(r) do
    {rs, cs} = size(matrix)

    if row * col == rs * cs do
      Result.ok(matrix)
    else
      Result.error(
        "It is not possible to reshape matrix! The numbers of element of matrix must be equal row * col."
      )
    end
  end
end
