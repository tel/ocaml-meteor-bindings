
open Goji

let tracker_package =
  register_package
    ~version:"1.0.7"
    ~doc:"Simple, push-based reactivity."
    "tracker"

let tracker_component =
  register_component
    ~version:"1.0.7"
    ~author:"Meteor Development Group"
    ~license:License.mit
    ~grabber:Grab.(sequence [
        http_get
          "https://raw.githubusercontent.com/meteor/meteor/devel/packages/tracker/tracker.js"
          "goji_entry.js"
      ])
    ~binding_author:"Joseph Abrahamson <me@jspha.com>"
    ~binding_version:"1.0.7"
    ~doc:"Simple, push-based reactivity."
    tracker_package "tracker"
    [
      section "Tracker"
        [ map_global "active"
            ~doc:"True if there is a current computation, meaning that \
                  dependencies on reactive data sources will be tracked \
                  and potentially cause the current computation to be rerun."
            ~read_only:true
            (bool @@ global "Tracker.active")
        ; structure "Computation"
            ~doc:"A Computation object represents code that is repeatedly rerun \
                  in response to reactive data changes. Computations don't have \
                  return values; they just perform actions, such as rerendering \
                  a template on the screen. Computations are created using \
                  Tracker.autorun. Use stop to prevent further rerunning of a \
                  computation."
            [ def_type "t" (abstract any)
            ; map_attribute "t" "stopped"
                ~doc:"True if this computation has been stopped."
                ~read_only:true
                bool
            ; map_attribute "t" "invalidated"
                ~doc:"True if this computation has been invalidated (and not yet \
                      rerun), or if it has been stopped."
                ~read_only:true
                bool
            ; map_attribute "t" "firstRun"
                ~doc:"True during the initial run of the computation at the time \
                      [Tracker.autorun] is called, and false on subsequent reruns \
                        and at other times."
                ~rename:"first_run"
                ~read_only:true
                bool
            ; map_method "t" "stop"
                ~doc:"Prevents this computation from rerunning."
                [] void
            ; map_method "t" "invalidate"
                ~doc:"Invalidates this computation so that it will be rerun."
                [] void
            ; map_method "t" "onInvalidate"
                ~doc:"Registers [callback] to run when this computation is next \
                      invalidated, or runs it immediately if the computation is \
                      already invalidated.  The callback is run exactly once and \
                      not upon future invalidations unless [onInvalidate] is called \
                      again after the computation becomes valid again."
                [ curry_arg "callback"
                    ~doc:"Function to be called on invalidation."
                    (callback
                       [ curry_arg "computation"
                           ~doc:"The computation that was invalidated"
                           (abbrv "t" @@ arg 0)
                       ]
                       void @@ arg 0)
                ]
                void
            ]
        ; structure "Dependency"
            ~doc:"A Dependency represents an atomic unit of reactive data that a \
                  computation might depend on. Reactive data sources such as Session or \
                  Minimongo internally create different Dependency objects for different \
                  pieces of data, each of which may be depended on by multiple computations. \
                  When the data changes, the computations are invalidated."
            [ def_type "t" (abstract any)
            ; map_constructor "t" "make" [] "Tracker.Dependency"
            ; map_method "t" "depend"
                ~doc:"Declares that the current computation depends on [dependency]. \
                      The computation will be invalidated the next time [dependency] changes. \
                      If there is no current computation it does nothing and returns false. \
                      Returns true if the computation is a new dependent of [dependency] \
                      rather than an existing one."
                [] void
            ; map_method "t" "depend"
                ~rename:"depend_on"
                ~doc:"Declares that a computation depends on [dependency]. The computation will be \
                      invalidated the next time [dependency] changes. Returns true if the computation \
                      is a new dependent of [dependency] rather than an existing one."
                [ curry_arg "computation"
                    ~doc:"The dependent computation."
                    (abbrv "Computation.t" @@ arg 0)] void
            ; map_method "t" "changed"
                ~doc:"Invalidate all dependent computations immediately and remove \
                      them as dependents."
                [] void
            ; map_method "t" "hasDependents"
                ~rename:"has_dependents"
                ~doc:"True if this Dependency has one or more dependent Computations, \
                      which would be invalidated if this Dependency were to change."
                [] bool
            ]
        ; map_global "current_computation"
            ~doc:"The current computation, or [null] if there isn't one. \
                  The current computation is the [Tracker.Computation] \
                  object created by the innermost active call to \
                  [Tracker.autorun], and it's the computation that gains \
                  dependencies when reactive data sources are accessed."
            ~read_only:true
            (option_null (abbrv "Computation.t") @@ global "Tracker.currentComputation")
        ; map_function "autorun"
            ~doc:"Run a function now and rerun it later whenever its dependencies \
                  change. Returns a Computation object that can be used to stop or \
                  observe the rerunning."
            [ curry_arg "runFunc"
                ~doc:"The function to run. It receives one argument: the Computation \
                      object that will be returned."
                (callback
                   [ curry_arg "computation"
                       ~doc:"The current computation"
                       (abbrv "Computation.t" @@ arg 0)
                   ]
                   void @@ arg 0) ]
            "Tracker.autorun" (abbrv "Computation.t")
        ; map_function "non_reactive"
            ~doc:"Run [f] with no current computation, returning the return value of \
                  [f]. Used to turn off reactivity for the duration of [f], so that \
                  reactive data sources accessed by [f] will not result in any \
                  computations being invalidated."
            [ curry_arg "runFunc"
                ~doc:"A function to call immediately, non-reactively."
                (callback [] (param "'a") @@ arg 0)
            ]
            "Tracker.nonreactive" (param "'a")
        ; map_function "on_invalidate"
            ~doc:"Registers a new [onInvalidate] callback on the current computation \
                  (which must exist), to be called immediately when the current \
                  computation is invalidated or stopped."
            [ curry_arg "callback"
                ~doc:"Function to be called on invalidation."
                (callback
                   [ curry_arg "computation"
                       ~doc:"The computation that was invalidated"
                       (abbrv "Computation.t" @@ arg 0)
                   ]
                   void @@ arg 0)
            ]
            "Tracker.onInvalidate" void
        ; map_function "after_flush"
            ~doc:"Schedules a function to be called during the next flush, or \
                  later in the current flush if one is in progress, after all \
                  invalidated computations have been rerun.  The function will \
                  be run once and not on subsequent flushes unless \
                  [afterFlush] is called again."
            [ curry_arg "runFunc"
                ~doc:"A function to call immediately, non-reactively."
                (callback [] void @@ arg 0)
            ]
            "Tracker.afterFlush" void
        ; map_function "flush"
            ~doc:"Process all reactive updates immediately and ensure that all \
                  invalidated computations are rerun."
            [] "Tracker.flush" void
        ]
    ]
