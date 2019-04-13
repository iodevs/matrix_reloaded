defmodule MatrixReloaded.Vector do
  @moduledoc """
  Provides a set of functions to work with vectors.

  Mostly functions is written for a row vectors. So if you'll need a similar
  functionality even for a column vectors you can use `transpose` function
  on row vector.
  """
  alias MatrixReloaded.Matrix

  @type t :: [number]
  @type column() :: [[number]]
  @type subvector :: number | t()

  @doc """
  Create a row vector of the specified size. Default values of vector
  is set to `0`. This value can be changed.

  Returns list of numbers.

  ## Examples

      iex> MatrixReloaded.Vector.row(4)
      [0, 0, 0, 0]

      iex> MatrixReloaded.Vector.row(4, 3.9)
      [3.9, 3.9, 3.9, 3.9]

  """

  @spec row(pos_integer, number) :: t()
  def row(size, val \\ 0) do
    List.duplicate(val, size)
  end

  @doc """
  Create a column vector of the specified size. Default values of vector
  is set to `0`. This value can be changed.

  Returns list of list number.

  ## Examples

      iex> MatrixReloaded.Vector.col(3)
      [[0], [0], [0]]

      iex> MatrixReloaded.Vector.col(3, 4)
      [[4], [4], [4]]

  """

  @spec col(pos_integer, number) :: column()
  def col(size, val \\ 0) do
    val |> List.duplicate(size) |> Enum.chunk_every(1)
  end

  @doc """
  Convert (transpose) a row vector to column and vice versa.

  ## Examples

      iex> MatrixReloaded.Vector.transpose([1, 2, 3])
      [[1], [2], [3]]

      iex(23)> MatrixReloaded.Vector.transpose([[1], [2], [3]])
      [1, 2, 3]

  """
  @spec transpose(t() | column()) :: column() | t()
  def transpose([hd | _] = vec) when is_list(hd) do
    List.flatten(vec)
  end

  def transpose(vec) do
    Enum.chunk_every(vec, 1)
  end

  @doc """
  Create row vector of alternating sequence of numbers.

  ## Examples

      iex> MatrixReloaded.Vector.row(5) |> MatrixReloaded.Vector.alternate_seq(1)
      [1, 0, 1, 0, 1]

      iex> MatrixReloaded.Vector.row(7) |> MatrixReloaded.Vector.alternate_seq(1, 3)
      [1, 0, 0, 1, 0, 0, 1]

  """

  @spec alternate_seq(t(), number, pos_integer) :: t()
  def alternate_seq(vec, val, step \\ 2) do
    Enum.map_every(vec, step, fn x -> x + val end)
  end

  @doc """
  Addition of two a row vectors. These two vectors must have a same size.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, vector}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Vector.add([1, 2, 3], [4, 5, 6])
      {:ok, [5, 7, 9]}

  """

  @spec add(t(), t()) :: Result.t(String.t(), t())
  def add([hd1 | _], [hd2 | _]) when is_list(hd1) or is_list(hd2) do
    Result.error("Vectors must be row type!")
  end

  def add(vec1, vec2) do
    if size(vec1) == size(vec2) do
      [vec1, vec2]
      |> List.zip()
      |> Enum.map(fn {x, y} -> x + y end)
      |> Result.ok()
    else
      Result.error("Size both vectors must be same!")
    end
  end

  @doc """
  Subtraction of two a row vectors. These two vectors must have a same size.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, vector}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Vector.sub([1, 2, 3], [4, 5, 6])
      {:ok, [-3, -3, -3]}

  """

  @spec sub(t(), t()) :: Result.t(String.t(), t())
  def sub([hd1 | _], [hd2 | _]) when is_list(hd1) or is_list(hd2) do
    Result.error("Vectors must be row type!")
  end

  def sub(vec1, vec2) do
    if size(vec1) == size(vec2) do
      [vec1, vec2]
      |> List.zip()
      |> Enum.map(fn {x, y} -> x - y end)
      |> Result.ok()
    else
      Result.error("Size both vectors must be same!")
    end
  end

  @doc """
  Scalar product of two a row vectors. These two vectors must have a same size.
  Otherwise you get an error message.

  Returns result, it means either tuple of `{:ok, number}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Vector.dot([1, 2, 3], [4, 5, 6])
      {:ok, 32}

  """

  @spec dot(t(), t()) :: Result.t(String.t(), number)
  def dot([hd1 | _], [hd2 | _]) when is_list(hd1) or is_list(hd2) do
    Result.error("Vectors must be row type!")
  end

  def dot(vec1, vec2) do
    if size(vec1) == size(vec2) do
      [vec1, vec2]
      |> List.zip()
      |> Enum.map(fn {x, y} -> x * y end)
      |> Enum.sum()
      |> Result.ok()
    else
      Result.error("Size both vectors must be same!")
    end
  end

  @doc """
  Inner product of two a row vectors. It produces a row vector where each
  element `i, j` is the product of elements `i, j` of the original two
  row vectors. These two vectors must have a same size. Otherwise you get
  an error message.

  Returns result, it means either tuple of `{:ok, vector}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Vector.inner_product([1, 2, 3], [4, 5, 6])
      {:ok, [4, 10, 18]}

  """

  @spec inner_product(t(), t()) :: Result.t(String.t(), t())
  def inner_product([hd1 | _], [hd2 | _]) when is_list(hd1) or is_list(hd2) do
    Result.error("Vectors must be row type!")
  end

  def inner_product(vec1, vec2) do
    if size(vec1) == size(vec2) do
      [vec1, vec2]
      |> List.zip()
      |> Enum.map(fn {x, y} -> x * y end)
      |> Result.ok()
    else
      Result.error("Size both vectors must be same!")
    end
  end

  @doc """
  Outer product of two a row vectors. It produces a matrix of dimension
  `{m, n}` where `m` and `n` are length (size) of row vectors. If input
  vectors aren't a row type you get an error message.

  Returns result, it means either tuple of `{:ok, matrix}` or `{:error, "msg"}`.

  ## Examples

      iex> MatrixReloaded.Vector.outer_product([1, 2, 3, 4], [1, 2, 3])
      {:ok,
          [
            [1, 2, 3],
            [2, 4, 6],
            [3, 6, 9],
            [4, 8, 12]
          ]
        }

  """

  @spec outer_product(t(), t()) :: Result.t(String.t(), Matrix.t())
  def outer_product([hd1 | _], [hd2 | _]) when is_list(hd1) or is_list(hd2) do
    Result.error("Vectors must be row type!")
  end

  def outer_product(vec1, vec2) do
    if 1 < size(vec1) and 1 < size(vec2) do
      vec1
      |> Enum.map(fn el -> mult_by_num(vec2, el) end)
      |> Result.ok()
    else
      Result.error("Vectors must contain at least two values!")
    end
  end

  @doc """
  Multiply a vector by number.

  ## Examples

      iex> MatrixReloaded.Vector.row(3, 2) |> MatrixReloaded.Vector.mult_by_num(3)
      [6, 6, 6]

      iex> MatrixReloaded.Vector.col(3, 2) |> MatrixReloaded.Vector.mult_by_num(3)
      [[6], [6], [6]]

  """

  @spec mult_by_num(t() | column(), number) :: t() | column()
  def mult_by_num([hd | _] = vec, val) when is_list(hd) do
    vec
    |> transpose()
    |> mult_by_num(val)
    |> transpose()
  end

  def mult_by_num(vec, val) do
    Enum.map(vec, fn x -> x * val end)
  end

  @doc """
  Update row vector by given a row subvector (list) of numbers or just by one number.
  The vector elements you want to change are given by the index. The index is a
  non-negative integer and determines the position of the element in the vector.

  Returns result, it means either tuple of `{:ok, vector}` or `{:error, "msg"}`.
  ##  Example:
      iex> vec = 0..10 |> Enum.to_list()
      iex> MatrixReloaded.Vector.update(vec, [0, 0, 0], 5)
      {:ok, [0, 1, 2, 3, 4, 0, 0, 0, 8, 9, 10]}

      iex> vec = 0..10 |> Enum.to_list()
      iex> MatrixReloaded.Vector.update(vec, 0, 5)
      {:ok, [0, 1, 2, 3, 4, 0, 6, 7, 8, 9, 10]}
  """
  @spec update(t(), number() | t(), non_neg_integer()) ::
          Result.t(String.t(), t())

  def update(vec, subvec, index)
      when is_list(vec) and is_number(subvec) and is_integer(index) do
    update(vec, [subvec], index)
  end

  def update(vec, subvec, index)
      when is_list(vec) and is_list(subvec) and is_integer(index) do
    len_vec = Kernel.length(vec)

    vec
    |> is_index_ok?(index)
    |> Result.and_then(&is_index_at_vector?(&1, len_vec, index))
    |> Result.and_then(&is_subvec_in_vec?(&1, len_vec, Kernel.length(subvec), index))
    |> Result.map(&make_update(&1, subvec, index))
  end

  @doc """
  Update row vector by given a row subvector (list) of numbers or by one number.
  The elements you want to change are given by the vector of indices. These
  indices must be a non-negative integers and determine the positions of
  the element in the vector.

  Returns result, it means either tuple of `{:ok, vector}` or `{:error, "msg"}`.
  ##  Example:
      iex> vec = 0..10 |> Enum.to_list()
      iex> MatrixReloaded.Vector.update_map(vec, [0, 0], [2, 7])
      {:ok, [0, 1, 0, 0, 4, 5, 6, 0, 0, 9, 10]}

      iex> vec = 0..10 |> Enum.to_list()
      iex> MatrixReloaded.Vector.update_map(vec, 0, [2, 7])
      {:ok, [0, 1, 0, 3, 4, 5, 6, 0, 8, 9, 10]}
  """
  @spec update_map(t(), number() | t(), list(non_neg_integer())) ::
          Result.t(String.t(), t())
  def update_map(vec, subvec, position_indices) do
    Enum.reduce(position_indices, {:ok, vec}, fn position, acc ->
      Result.and_then(acc, &update(&1, subvec, position))
    end)
  end

  @doc """
  The size of the vector.

  Returns a positive integer.

  ## Example:

      iex> MatrixReloaded.Vector.row(3) |> MatrixReloaded.Vector.size()
      3

      iex> MatrixReloaded.Vector.col(4, -1) |> MatrixReloaded.Vector.size()
      4

  """
  @spec size(t()) :: non_neg_integer
  def size(vec), do: length(vec)

  defp make_update(vec, subvec, index) do
    len_subvec = Kernel.length(subvec)

    vec
    |> Enum.with_index()
    |> Enum.map(fn {val, i} ->
      if i in index..(index + len_subvec - 1) do
        subvec |> Enum.at(i - index)
      else
        val
      end
    end)
  end

  defp is_index_ok?(vec, idx) when is_integer(idx) and 0 <= idx do
    Result.ok(vec)
  end

  defp is_index_ok?(_vec, idx) when is_number(idx) do
    Result.error("The index must be integer number greater or equal to zero!")
  end

  defp is_index_at_vector?(
         vec,
         len,
         index,
         method \\ :update
       )

  defp is_index_at_vector?(vec, len, idx, _method)
       when idx <= len do
    Result.ok(vec)
  end

  defp is_index_at_vector?(
         _vec,
         _len,
         _idx,
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} the #{vec_or_subvec(method)}. The index is outside of vector!"
    )
  end

  defp is_subvec_in_vec?(
         vec,
         len_vec,
         len_subvec,
         index,
         method \\ :update
       )

  defp is_subvec_in_vec?(
         vec,
         len_vec,
         len_subvec,
         idx,
         _method
       )
       when len_subvec + idx <= len_vec do
    Result.ok(vec)
  end

  defp is_subvec_in_vec?(
         _vec,
         _len_vec,
         _len_subvec,
         idx,
         method
       ) do
    Result.error(
      "You can not #{Atom.to_string(method)} #{vec_or_subvec(method)} on given position #{idx}. A part of subvector is outside of matrix!"
    )
  end

  defp vec_or_subvec(:update) do
    "vector"
  end

  # defp vec_or_subvec(:get) do
  #   "subvector or element"
  # end
end
