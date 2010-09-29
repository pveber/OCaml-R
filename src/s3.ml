(*********************************************************************************)
(*                OCaml-R                                                        *)
(*                                                                               *)
(*    Copyright (C) 2008-2010 Institut National de Recherche en                  *)
(*    Informatique et en Automatique. All rights reserved.                       *)
(*                                                                               *)
(*    Copyright (C) 2009-2010 Guillaume Yziquel. All rights reserved.            *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU General Public License as                    *)
(*    published by the Free Software Foundation; either version 3 of the         *)
(*    License, or  any later version.                                            *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the               *)
(*    GNU Library General Public License for more details.                       *)
(*                                                                               *)
(*    You should have received a copy of the GNU General Public                  *)
(*    License along with this program; if not, write to the Free Software        *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*             guillaume.yziquel@citycable.ch                                    *)
(*********************************************************************************)

(**  Get the S3 class of a given SEXP.
  *
  *  r_s3_class takes a SEXP as argument, and returns the S3 class
  *  attribute of the given SEXP.
  *)

external s3_class : sexp -> sexp = "ocamlr_s3_class"

external aux_get_attrib : sexp -> symsxp -> sexp = "ocamlr_get_attrib"
let get_attrib s name = aux_get_attrib s (install name)

external get_attributes : sexp -> pairlist = "ocamlr_get_attributes"

class type ['a] s3 = object
  val underlying    : 'a t
  method attribute  : string -> sexp
  method attributes : (Specification.symbol * sexp) list
  method classes    : string list
end

class ['a] s3_from_R r : ['a] s3 = object
  val underlying = r
  method attribute s = get_attrib (underlying : 'a t :> sexp) s
  method attributes = List.map
    begin function (a, x) -> (Specification.of_symbol a), x end
    (list_of_pairlist (get_attributes (underlying : 'a t :> sexp)))
  method classes = strings_of_t ((get_attrib (underlying : 'a t :> sexp) "class") : sexp :> string list t)
end

