/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Ocaml proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#include <string>
#include <exception>

# define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)

namespace Swig {
  /* base class for director exceptions */
  class DirectorException : public std::exception {
    protected:
      std::string swig_msg;

    public:
      DirectorException(const char *msg="") : swig_msg(msg) {
      }

      virtual ~DirectorException() SWIG_NOEXCEPT {
      }

      const char *what() const SWIG_NOEXCEPT {
        return swig_msg.c_str();
      }
  };

  /* type mismatch in the return value from a Ocaml method call */
  class DirectorTypeMismatchException : public DirectorException {
    public:
      DirectorTypeMismatchException(const char *msg="") : DirectorException(msg) {
      }
  };

  /* any Ocaml exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {};

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
    public:
      DirectorPureVirtualException(const char *msg="") : DirectorException(msg) {
      }

      static void raise(const char *msg) {
        throw DirectorPureVirtualException(msg);
      }
  };

  /* director base class */
  class Director {
    private:
      /* pointer to the wrapped ocaml object */
      value swig_self;
      /* flag indicating whether the object is owned by ocaml or c++ */
      mutable bool swig_disown_flag;

    public:
      /* wrap a ocaml object. */
      Director(value self) : swig_self(self), swig_disown_flag(false) {
        caml_register_global_root(&swig_self);
      }

      /* discard our reference at destruction */
      virtual ~Director() {
        caml_remove_global_root(&swig_self);
        swig_disown();
        // Disown is safe here because we're just divorcing a reference that points to us.
      }

      /* return a pointer to the wrapped ocaml object */
      value swig_get_self() const {
	  return swig_self;
      }

      /* acquire ownership of the wrapped ocaml object (the sense of "disown" is from ocaml) */
      void swig_disown() const {
        if (!swig_disown_flag) {
          swig_disown_flag=true;
          caml_callback(*caml_named_value("caml_obj_disown"),swig_self);
        }
      }
  };
}

