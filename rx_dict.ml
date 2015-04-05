
module type S = sig
  type t
  type 'a key

  val make_key : unit -> 'a key

  val v : t
  val get : t -> 'a key -> 'a option
  val set : t -> 'a key -> 'a -> t
  val modify : ('a -> 'a) -> 'a key -> t -> t
end

module Make () = struct

  module IMap =
    Map.Make(struct type t = int let compare = Pervasives.compare end)

  type t = exn IMap.t

  type 'a key =
    { index : int
    ; dep   : Tracker.Dependency.t
    ; make  : 'a -> exn
    ; get   : exn -> 'a option
    }

  let last_index = ref 0

  let make_key (type a) () =
    let module M = struct exception E of a end in
    incr last_index;
    { index = !last_index
    ; dep   = Tracker.Dependency.make ()
    ; make  = (fun x -> M.E x)
    ; get   = (function M.E x -> Some x | _ -> None)
    }

  let empty = IMap.empty

  let get st k =
    if Tracker.active () then Tracker.Dependency.depend k.dep;
    try l.get (IMap.find k.index st) with
    | Not_found -> None

  let set st k v =
    let mp = IMap.add l.index (k.make v) st in
    Tracker.Dependency.changed k.dep;
    mp

  let modify f k st =
    try
      let x = l.get (IMap.find k.index st) in
      set st k (f x)
    with
    | Not_found -> t

end
