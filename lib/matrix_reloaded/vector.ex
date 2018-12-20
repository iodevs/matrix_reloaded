defmodule MatrixReloaded.Vector do
  @moduledoc """
  Provides a set of functions to work with vectors.
  """

  @type t :: list(number)

  @doc """
  Create a row vector of the specified size. Default values of vector
  is set to 0. This value can be changed. See example below.

  Returns list of numbers.

  ## Examples

      iex> MatrixReloaded.Vector.row(4)
      [0, 0, 0, 0]

      iex> MatrixReloaded.Vector.row(4, 3.9)
      [3.9, 3.9, 3.9, 3.9]

  """

  @spec row(pos_integer, number) :: Vector.t()
  def row(size, val \\ 0) do
    List.duplicate(val, size)
  end

  @doc """
  Create a column vector of the specified size. Default values of vector
  is set to 0. This value can be changed. See example below.

  Returns list of list number.

  ## Examples

      iex> MatrixReloaded.Vector.col(3)
      [[0], [0], [0]]

      iex> MatrixReloaded.Vector.col(3, 4)
      [[4], [4], [4]]

  """

  @spec col(pos_integer, number) :: [Vector.t()]
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
  @spec transpose(Vector.t()) :: Vector.t()
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

  @spec alternate_seq(Vector.t(), number, pos_integer) :: Vector.t()
  def alternate_seq(vec, val, step \\ 2) do
    Enum.map_every(vec, step, fn x -> x + val end)
  end

  @doc """
  Addition of two a row vectors. These two vectors must have a same size.
  Otherwise you get error message.

  Returns result, it means either tuple of {:ok, vector} or {:error, "msg"}.

  ## Examples

      iex> MatrixReloaded.Vector.add([1, 2, 3], [4, 5, 6])
      {:ok, [5, 7, 9]}

  """

  @spec add(Vector.t(), Vector.t()) :: Result.t(String.t(), Vector.t())
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
  Otherwise you get error message.

  Returns result, it means either tuple of {:ok, vector} or {:error, "msg"}.

  ## Examples

      iex> MatrixReloaded.Vector.sub([1, 2, 3], [4, 5, 6])
      {:ok, [-3, -3, -3]}

  """

  @spec sub(Vector.t(), Vector.t()) :: Result.t(String.t(), Vector.t())
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
  Otherwise you get error message.

  Returns result, it means either tuple of {:ok, number} or {:error, "msg"}.

  ## Examples

      iex> MatrixReloaded.Vector.dot([1, 2, 3], [4, 5, 6])
      {:ok, 32}

  """

  @spec dot(Vector.t(), Vector.t()) :: Result.t(String.t(), number)
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
  Multiply a row vector by number.

  ## Examples

      iex> MatrixReloaded.Vector.row(3, 2) |> MatrixReloaded.Vector.mult_by_num(3)
      [6, 6, 6]

  """

  @spec mult_by_num(Vector.t(), number) :: Vector.t()
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
  @spec size(Vector.t()) :: non_neg_integer
  def size(vec), do: length(vec)
end
