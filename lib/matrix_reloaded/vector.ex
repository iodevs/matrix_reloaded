defmodule MatrixReloaded.Vector do
  @moduledoc """
  Provides a set of functions to work with vectors.

  Mostly functions is written for a row vectors. So if you'll need a similar
  functionality even for a column vectors you can use `transpose` function
  on row vector.
  """
  alias MatrixReloaded.Matrix

  @type t :: [number]

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

  @spec col(pos_integer, number) :: [t()]
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
  @spec transpose(t() | [t()]) :: t() | [t()]
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

  @spec mult_by_num(t() | [t()], number) :: t() | [t()]
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
end
