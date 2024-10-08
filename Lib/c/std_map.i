/* -----------------------------------------------------------------------------
 * std_map.i
 *
 * SWIG typemaps for std::map
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::map
// ------------------------------------------------------------------------

%{
#include <map>
#include <stdexcept>
%}

namespace std {
  template<class K, class T, class C = std::less<K> > class map {
    public:
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef K key_type;
      typedef T mapped_type;
      typedef std::pair< const K, T > value_type;
      typedef value_type* pointer;
      typedef const value_type* const_pointer;
      typedef value_type& reference;
      typedef const value_type& const_reference;

      map();
      map(const map& other);

      size_t size() const;
      bool empty() const;
      void clear();
      %extend {
        const T& get(const K& key) throw (std::out_of_range) {
          std::map< K, T, C >::iterator i = self->find(key);
          if (i != self->end())
            return i->second;
          else
            throw std::out_of_range("key not found");
        }
        void set(const K& key, const T& x) {
          (*self)[key] = x;
        }
        void del(const K& key) throw (std::out_of_range) {
          std::map< K, T, C >::iterator i = self->find(key);
          if (i != self->end())
            self->erase(i);
          else
            throw std::out_of_range("key not found");
        }
        bool has_key(const K& key) const {
          std::map< K, T, C >::const_iterator i = self->find(key);
          return i != self->end();
        }
      }
  };
}
