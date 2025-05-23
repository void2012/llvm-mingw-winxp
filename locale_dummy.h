#pragma once

namespace std {
inline namespace __1 {

template <unsigned _Np>
struct __widen_from_utf8 {
  template <class _OutputIterator>
  _OutputIterator operator()(_OutputIterator __s, const char* __nb, const char* __ne) const;
};

template <>
struct __widen_from_utf8<8> {
  template <class _OutputIterator>
   _OutputIterator operator()(_OutputIterator __s, const char* __nb, const char* __ne) const {
    for (; __nb < __ne; ++__nb, ++__s)
      *__s = *__nb;
    return __s;
  }
};

template <>
struct __widen_from_utf8<16> {
  template <class _OutputIterator>
   _OutputIterator operator()(_OutputIterator __s, const char* __nb, const char* __ne) const {
    return __s;
  }
};

template <unsigned _Np>
struct __narrow_to_utf8 {
  template <class _OutputIterator, class _CharT>
  _OutputIterator operator()(_OutputIterator __s, const _CharT* __wb, const _CharT* __we) const;
};

template <>
struct __narrow_to_utf8<8> {
  template <class _OutputIterator, class _CharT>
   _OutputIterator operator()(_OutputIterator __s, const _CharT* __wb, const _CharT* __we) const {
    for (; __wb < __we; ++__wb, ++__s)
      *__s = *__wb;
    return __s;
  }
};
template <>
struct __narrow_to_utf8<16> {
  template <class _OutputIterator, class _CharT>
   _OutputIterator operator()(_OutputIterator __s, const _CharT* __wb, const _CharT* __we) const {
    return __s;
  }
};

}
}
