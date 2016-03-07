
(* This file is free software, part of sequence. See file "license" for more details. *)


(** {1 Simple and Efficient Iterators}

    Version of {!Sequence} with labels

    @since 0.5.5 *)

type +'a t = ('a -> unit) -> unit
(** A sequence of values of type ['a]. If you give it a function ['a -> unit]
    it will be applied to every element of the sequence successively. *)

type +'a sequence = 'a t

type (+'a, +'b) t2 = ('a -> 'b -> unit) -> unit
(** Sequence of pairs of values of type ['a] and ['b]. *)

(** {2 Build a sequence} *)

val from_iter : (('a -> unit) -> unit) -> 'a t
(** Build a sequence from a iter function *)

val from_fun : (unit -> 'a option) -> 'a t
(** Call the function repeatedly until it returns None. This
    sequence is transient, use {!persistent} if needed! *)

val empty : 'a t
(** Empty sequence. It contains no element. *)

val singleton : 'a -> 'a t
(** Singleton sequence, with exactly one element. *)

val doubleton : 'a -> 'a -> 'a t
(** Sequence with exactly two elements *)

val cons : 'a -> 'a t -> 'a t
(** [cons x l] yields [x], then yields from [l].
    Same as [append (singleton x) l] *)

val snoc : 'a t -> 'a -> 'a t
(** Same as {!cons} but yields the element after iterating on [l] *)

val return : 'a -> 'a t
(** Synonym to {!singleton} *)

val pure : 'a -> 'a t
(** Synonym to {!singleton} *)

val repeat : 'a -> 'a t
(** Infinite sequence of the same element. You may want to look
    at {!take} and the likes if you iterate on it. *)

val iterate : ('a -> 'a) -> 'a -> 'a t
(** [iterate f x] is the infinite sequence [x, f(x), f(f(x)), ...] *)

val forever : (unit -> 'b) -> 'b t
(** Sequence that calls the given function to produce elements.
    The sequence may be transient (depending on the function), and definitely
    is infinite. You may want to use {!take} and {!persistent}. *)

val cycle : 'a t -> 'a t
(** Cycle forever through the given sequence. Assume the given sequence can
    be traversed any amount of times (not transient).  This yields an
    infinite sequence, you should use something like {!take} not to loop
    forever. *)

(** {2 Consume a sequence} *)

val iter : f:('a -> unit) -> 'a t -> unit
(** Consume the sequence, passing all its arguments to the function.
    Basically [iter f seq] is just [seq f]. *)

val iteri : f:(int -> 'a -> unit) -> 'a t -> unit
(** Iterate on elements and their index in the sequence *)

val fold : f:('a -> 'b -> 'a) -> init:'a -> 'b t -> 'a
(** Fold over elements of the sequence, consuming it *)

val foldi : f:('a -> int -> 'b -> 'a) -> init:'a -> 'b t -> 'a
(** Fold over elements of the sequence and their index, consuming it *)

val map : f:('a -> 'b) -> 'a t -> 'b t
(** Map objects of the sequence into other elements, lazily *)

val mapi : f:(int -> 'a -> 'b) -> 'a t -> 'b t
(** Map objects, along with their index in the sequence *)

val map_by_2 : f:('a -> 'a -> 'a) -> 'a t -> 'a t
  (** Map objects two by two. lazily.
      The last element is kept in the sequence if the count is odd.
      @since NEXT_RELEASE *)

val for_all : f:('a -> bool) -> 'a t -> bool
(** Do all elements satisfy the predicate? *)

val exists : f:('a -> bool) -> 'a t -> bool
(** Exists there some element satisfying the predicate? *)

val mem : ?eq:('a -> 'a -> bool) -> x:'a -> 'a t -> bool
(** Is the value a member of the sequence?
    @param eq the equality predicate to use (default [(=)]) *)

val find : f:('a -> 'b option) -> 'a t -> 'b option
(** Find the first element on which the function doesn't return [None] *)

val length : 'a t -> int
(** How long is the sequence? Forces the sequence. *)

val is_empty : 'a t -> bool
(** Is the sequence empty? Forces the sequence. *)

(** {2 Transform a sequence} *)

val filter : f:('a -> bool) -> 'a t -> 'a t
(** Filter on elements of the sequence *)

val append : 'a t -> 'a t -> 'a t
(** Append two sequences. Iterating on the result is like iterating
    on the first, then on the second. *)

val concat : 'a t t -> 'a t
(** Concatenate a sequence of sequences into one sequence. *)

val flatten : 'a t t -> 'a t
(** Alias for {!concat} *)

val flat_map : f:('a -> 'b t) -> 'a t -> 'b t
(** Monadic bind. Intuitively, it applies the function to every
    element of the initial sequence, and calls {!concat}. *)

val filter_map : f:('a -> 'b option) -> 'a t -> 'b t
(** Map and only keep non-[None] elements *)

val intersperse : x:'a -> 'a t -> 'a t
(** Insert the single element between every element of the sequence *)

(** {2 Caching} *)

val persistent : 'a t -> 'a t
(** Iterate on the sequence, storing elements in an efficient internal structure..
    The resulting sequence can be iterated on as many times as needed.
    {b Note}: calling persistent on an already persistent sequence
    will still make a new copy of the sequence! *)

val persistent_lazy : 'a t -> 'a t
(** Lazy version of {!persistent}. When calling [persistent_lazy s],
    a new sequence [s'] is immediately returned (without actually consuming
    [s]) in constant time; the first time [s'] is iterated on,
    it also consumes [s] and caches its content into a inner data
    structure that will back [s'] for future iterations.

    {b warning}: on the first traversal of [s'], if the traversal
    is interrupted prematurely ({!take}, etc.) then [s'] will not be
    memorized, and the next call to [s'] will traverse [s] again. *)

(** {2 Misc} *)

val sort : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
(** Sort the sequence. Eager, O(n) ram and O(n ln(n)) time.
    It iterates on elements of the argument sequence immediately,
    before it sorts them. *)

val sort_uniq : ?cmp:('a -> 'a -> int) -> 'a t -> 'a t
(** Sort the sequence and remove duplicates. Eager, same as [sort] *)

val group : ?eq:('a -> 'a -> bool) -> 'a t -> 'a list t
(** Group equal consecutive elements. *)

val uniq : ?eq:('a -> 'a -> bool) -> 'a t -> 'a t
(** Remove consecutive duplicate elements. Basically this is
    like [fun seq -> map List.hd (group seq)]. *)

val product : 'a t -> 'b t -> ('a * 'b) t
(** Cartesian product of the sequences. When calling [product a b],
    the caller {b MUST} ensure that [b] can be traversed as many times
    as required (several times), possibly by calling {!persistent} on it
    beforehand. *)

val product2 : 'a t -> 'b t -> ('a, 'b) t2
(** Binary version of {!product}. Same requirements. *)

val join : join_row:('a -> 'b -> 'c option) -> 'a t -> 'b t -> 'c t
(** [join ~join_row a b] combines every element of [a] with every
    element of [b] using [join_row]. If [join_row] returns None, then
    the two elements do not combine. Assume that [b] allows for multiple
    iterations. *)

val unfoldr : ('b -> ('a * 'b) option) -> 'b -> 'a t
(** [unfoldr f b] will apply [f] to [b]. If it
    yields [Some (x,b')] then [x] is returned
    and unfoldr recurses with [b']. *)

val scan : ('b -> 'a -> 'b) -> 'b -> 'a t -> 'b t
(** Sequence of intermediate results *)

val max : ?lt:('a -> 'a -> bool) -> 'a t -> 'a option
(** Max element of the sequence, using the given comparison function.
    @return None if the sequence is empty, Some [m] where [m] is the maximal
    element otherwise *)

val min : ?lt:('a -> 'a -> bool) -> 'a t -> 'a option
(** Min element of the sequence, using the given comparison function.
    see {!max} for more details. *)

val head : 'a t -> 'a option
(** First element, if any, otherwise [None] *)

val head_exn : 'a t -> 'a
(** First element, if any, fails
    @raise Invalid_argument if the sequence is empty *)

val take : int -> 'a t -> 'a t
(** Take at most [n] elements from the sequence. Works on infinite
    sequences. *)

val take_while : f:('a -> bool) -> 'a t -> 'a t
(** Take elements while they satisfy the predicate, then stops iterating.
    Will work on an infinite sequence [s] if the predicate is false for at
    least one element of [s]. *)

val fold_while : f:('a -> 'b -> 'a * [`Stop | `Continue]) -> init:'a -> 'b t -> 'a
(** Folds over elements of the sequence, stopping early if the accumulator
    returns [('a, `Stop)] *)

val drop : int -> 'a t -> 'a t
(** Drop the [n] first elements of the sequence. Lazy. *)

val drop_while : f:('a -> bool) -> 'a t -> 'a t
(** Predicate version of {!drop} *)

val rev : 'a t -> 'a t
(** Reverse the sequence. O(n) memory and time, needs the
    sequence to be finite. The result is persistent and does
    not depend on the input being repeatable. *)

(** {2 Binary sequences} *)

val empty2 : ('a, 'b) t2

val is_empty2 : (_, _) t2 -> bool

val length2 : (_, _) t2 -> int

val zip : ('a, 'b) t2 -> ('a * 'b) t

val unzip : ('a * 'b) t -> ('a, 'b) t2

val zip_i : 'a t -> (int, 'a) t2
(** Zip elements of the sequence with their index in the sequence *)

val fold2 : f:('c -> 'a -> 'b -> 'c) -> init:'c -> ('a, 'b) t2 -> 'c

val iter2 : f:('a -> 'b -> unit) -> ('a, 'b) t2 -> unit

val map2 : f:('a -> 'b -> 'c) -> ('a, 'b) t2 -> 'c t

val map2_2 : ('a -> 'b -> 'c) -> ('a -> 'b -> 'd) -> ('a, 'b) t2 -> ('c, 'd) t2
(** [map2_2 f g seq2] maps each [x, y] of seq2 into [f x y, g x y] *)

(** {2 Basic data structures converters} *)

val to_list : 'a t -> 'a list
(** Convert the sequence into a list. Preserves order of elements.
    This function is tail-recursive, but consumes 2*n memory.
    If order doesn't matter to you, consider {!to_rev_list}. *)

val to_rev_list : 'a t -> 'a list
(** Get the list of the reversed sequence (more efficient than {!to_list}) *)

val of_list : 'a list -> 'a t

val on_list : ('a t -> 'b t) -> 'a list -> 'b list
(** [on_list f l] is equivalent to [to_list @@ f @@ of_list l]. *)

val to_opt : 'a t -> 'a option
(** Alias to {!head} *)

val to_array : 'a t -> 'a array
(** Convert to an array. Currently not very efficient because
    an intermediate list is used. *)

val of_array : 'a array -> 'a t

val of_array_i : 'a array -> (int * 'a) t
(** Elements of the array, with their index *)

val of_array2 : 'a array -> (int, 'a) t2

val array_slice : 'a array -> int -> int -> 'a t
(** [array_slice a i j] Sequence of elements whose indexes range
    from [i] to [j] *)

val of_opt : 'a option -> 'a t
(** Iterate on 0 or 1 values. *)

val of_stream : 'a Stream.t -> 'a t
(** Sequence of elements of a stream (usable only once) *)

val to_stream : 'a t -> 'a Stream.t
(** Convert to a stream. linear in memory and time (a copy is made in memory) *)

val to_stack : 'a Stack.t -> 'a t -> unit
(** Push elements of the sequence on the stack *)

val of_stack : 'a Stack.t -> 'a t
(** Sequence of elements of the stack (same order as [Stack.iter]) *)

val to_queue : 'a Queue.t -> 'a t -> unit
(** Push elements of the sequence into the queue *)

val of_queue : 'a Queue.t -> 'a t
(** Sequence of elements contained in the queue, FIFO order *)

val hashtbl_add : ('a, 'b) Hashtbl.t -> ('a * 'b) t -> unit
(** Add elements of the sequence to the hashtable, with
    Hashtbl.add *)

val hashtbl_replace : ('a, 'b) Hashtbl.t -> ('a * 'b) t -> unit
(** Add elements of the sequence to the hashtable, with
    Hashtbl.replace (erases conflicting bindings) *)

val to_hashtbl : ('a * 'b) t -> ('a, 'b) Hashtbl.t
(** Build a hashtable from a sequence of key/value pairs *)

val to_hashtbl2 : ('a, 'b) t2 -> ('a, 'b) Hashtbl.t
(** Build a hashtable from a sequence of key/value pairs *)

val of_hashtbl : ('a, 'b) Hashtbl.t -> ('a * 'b) t
(** Sequence of key/value pairs from the hashtable *)

val of_hashtbl2 : ('a, 'b) Hashtbl.t -> ('a, 'b) t2
(** Sequence of key/value pairs from the hashtable *)

val hashtbl_keys : ('a, 'b) Hashtbl.t -> 'a t
val hashtbl_values : ('a, 'b) Hashtbl.t -> 'b t

val of_str : string -> char t
val to_str :  char t -> string

val concat_str : string t -> string
(** Concatenate strings together, eagerly.
    Also see {!intersperse} to add a separator. *)

exception OneShotSequence
(** Raised when the user tries to iterate several times on
    a transient iterator *)

val of_in_channel : in_channel -> char t
(** Iterates on characters of the input (can block when one
    iterates over the sequence). If you need to iterate
    several times on this sequence, use {!persistent}.
    @raise OneShotSequence when used more than once. *)

val to_buffer : char t -> Buffer.t -> unit
(** Copy content of the sequence into the buffer *)

val int_range : start:int -> stop:int -> int t
(** Iterator on integers in [start...stop] by steps 1. Also see
    {!(--)} for an infix version. *)

val int_range_dec : start:int -> stop:int -> int t
(** Iterator on decreasing integers in [stop...start] by steps -1.
    See {!(--^)} for an infix version *)

val of_set : (module Set.S with type elt = 'a and type t = 'b) -> 'b -> 'a t
(** Convert the given set to a sequence. The set module must be provided. *)

val to_set : (module Set.S with type elt = 'a and type t = 'b) -> 'a t -> 'b
(** Convert the sequence to a set, given the proper set module *)

type 'a gen = unit -> 'a option
type 'a klist = unit -> [`Nil | `Cons of 'a * 'a klist]

val of_gen : 'a gen -> 'a t
(** Traverse eagerly the generator and build a sequence from it *)

val to_gen : 'a t -> 'a gen
(** Make the sequence persistent (O(n)) and then iterate on it. Eager. *)

val of_klist : 'a klist -> 'a t
(** Iterate on the lazy list *)

val to_klist : 'a t -> 'a klist
(** Make the sequence persistent and then iterate on it. Eager. *)

(** {2 Functorial conversions between sets and sequences} *)

module Set : sig
  module type S = sig
    include Set.S
    val of_seq : elt sequence -> t
    val to_seq : t -> elt sequence
    val to_list : t -> elt list
    val of_list : elt list -> t
  end

  (** Create an enriched Set module from the given one *)
  module Adapt(X : Set.S) : S with type elt = X.elt and type t = X.t

  (** Functor to build an extended Set module from an ordered type *)
  module Make(X : Set.OrderedType) : S with type elt = X.t
end

(** {2 Conversion between maps and sequences.} *)

module Map : sig
  module type S = sig
    include Map.S
    val to_seq : 'a t -> (key * 'a) sequence
    val of_seq : (key * 'a) sequence -> 'a t
    val keys : 'a t -> key sequence
    val values : 'a t -> 'a sequence
    val to_list : 'a t -> (key * 'a) list
    val of_list : (key * 'a) list -> 'a t
  end

  (** Adapt a pre-existing Map module to make it sequence-aware *)
  module Adapt(M : Map.S) : S with type key = M.key and type 'a t = 'a M.t

  (** Create an enriched Map module, with sequence-aware functions *)
  module Make(V : Map.OrderedType) : S with type key = V.t
end

(** {2 Infinite sequences of random values} *)

val random_int : int -> int t
(** Infinite sequence of random integers between 0 and
    the given higher bound (see Random.int) *)

val random_bool : bool t
(** Infinite sequence of random bool values *)

val random_float : float -> float t

val random_array : 'a array -> 'a t
(** Sequence of choices of an element in the array *)

val random_list : 'a list -> 'a t
(** Infinite sequence of random elements of the list. Basically the
    same as {!random_array}. *)

val shuffle : 'a t -> 'a t
(** [shuffle seq] returns a perfect shuffle of [seq].
    Uses O(length seq) memory and time. Eager.
    @since NEXT_RELEASE *)

val shuffle_buffer : n:int -> 'a t -> 'a t
(** [shuffle_buffer n seq] returns a sequence of element of [seq] in random
    order. The shuffling is not uniform. Uses O(n) memory.

    The first [n] elements of the sequence are consumed immediately. The
    rest is consumed lazily.
    @since NEXT_RELEASE *)

(** {2 Sampling} *)

val sample : n:int -> 'a t -> 'a array
  (** [sample n seq] returns k samples of [seq], with uniform probability.
      It will consume the sequence and use O(n) memory.

      It returns an array of size [min (length seq) n].
      @since NEXT_RELEASE *)

(** {2 Infix functions} *)

module Infix : sig
  val (--) : int -> int -> int t
  (** [a -- b] is the range of integers from [a] to [b], both included,
      in increasing order. It will therefore be empty if [a > b]. *)

  val (--^) : int -> int -> int t
  (** [a --^ b] is the range of integers from [b] to [a], both included,
      in decreasing order (starts from [a]).
      It will therefore be empty if [a < b]. *)

  val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
  (** Monadic bind (infix version of {!flat_map} *)

  val (>|=) : 'a t -> ('a -> 'b) -> 'b t
  (** Infix version of {!map} *)

  val (<*>) : ('a -> 'b) t -> 'a t -> 'b t
  (** Applicative operator (product+application) *)

  val (<+>) : 'a t -> 'a t -> 'a t
  (** Concatenation of sequences *)
end

include module type of Infix


(** {2 Pretty printing of sequences} *)

val pp_seq : ?sep:string -> (Format.formatter -> 'a -> unit) ->
  Format.formatter -> 'a t -> unit
(** Pretty print a sequence of ['a], using the given pretty printer
    to print each elements. An optional separator string can be provided. *)

val pp_buf : ?sep:string -> (Buffer.t -> 'a -> unit) ->
  Buffer.t -> 'a t -> unit
(** Print into a buffer *)

val to_string : ?sep:string -> ('a -> string) -> 'a t -> string
(** Print into a string *)

(** {2 Basic IO}

    Very basic interface to manipulate files as sequence of chunks/lines. The
    sequences take care of opening and closing files properly; every time
    one iterates over a sequence, the file is opened/closed again.

    Example: copy a file ["a"] into file ["b"], removing blank lines:

    {[
      Sequence.(IO.lines_of "a" |> filter (fun l-> l<> "") |> IO.write_lines "b");;
    ]}

    By chunks of [4096] bytes:

    {[
      Sequence.IO.(chunks_of ~size:4096 "a" |> write_to "b");;
    ]}

    Read the lines of a file into a list:

    {[
      Sequence.IO.lines "a" |> Sequence.to_list
    ]}

*)

module IO : sig
  val lines_of : ?mode:int -> ?flags:open_flag list ->
    string -> string t
  (** [lines_of filename] reads all lines of the given file. It raises the
      same exception as would opening the file and read from it, except
      from [End_of_file] (which is caught). The file is {b always} properly
      closed.
      Every time the sequence is iterated on, the file is opened again, so
      different iterations might return different results
      @param mode default [0o644]
      @param flags default: [[Open_rdonly]] *)

  val chunks_of : ?mode:int -> ?flags:open_flag list -> ?size:int ->
    string -> string t
  (** Read chunks of the given [size] from the file. The last chunk might be
      smaller. Behaves like {!lines_of} regarding errors and options.
      Every time the sequence is iterated on, the file is opened again, so
      different iterations might return different results *)

  val write_to : ?mode:int -> ?flags:open_flag list ->
    string -> string t -> unit
  (** [write_to filename seq] writes all strings from [seq] into the given
      file. It takes care of opening and closing the file.
      @param mode default [0o644]
      @param flags used by [open_out_gen]. Default: [[Open_creat;Open_wronly]]. *)

  val write_bytes_to : ?mode:int -> ?flags:open_flag list ->
    string -> Bytes.t t -> unit
  (** *)

  val write_lines : ?mode:int -> ?flags:open_flag list ->
    string -> string t -> unit
  (** Same as {!write_to}, but intercales ['\n'] between each string *)

  val write_bytes_lines : ?mode:int -> ?flags:open_flag list ->
    string -> Bytes.t t -> unit
end
