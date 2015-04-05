
module type S = sig

  type 'a t

  val make : 'a -> 'a t
  val get  : 'a t -> 'a
  val set  : 'a t -> 'a -> unit
  val modify : ('a -> 'a) -> 'a t -> unit
end

module type Identifiable = sig
  type t
  val equal : t -> t -> bool
end

module Make (T : Identifiable) : S = struct

  type 'a t = 'a ref * Tracker.Dependency.t

  let make a = (ref a, Tracker.Dependency.make ())

  let get (rf, dep) =
    if Tracker.active () then Tracker.Dependency.depend dep;
    !rf

  let set (rf, dep) a =
    if not (T.equal !rf a)
    then begin
      rf := a;
      Tracker.Dependency.changed dep
    end

  let modify f (rf, dep) = set (rf, dep) (f !rf)

end
