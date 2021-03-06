;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2013 Nikita Karetnikov <nikita@karetnikov.org>
;;; Copyright © 2013 Ludovic Courtès <ludo@gnu.org>
;;; Copyright © 2013 Andreas Enge <andreas@enge.fr>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (gnu packages python)
  #:use-module ((guix licenses) #:select (bsd-3 psfl x11))
  #:use-module (gnu packages)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gdbm)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages openssl)
  #:use-module (gnu packages patchelf)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system python))

(define-public python
  (package
    (name "python")
    (version "2.7.5")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "http://www.python.org/ftp/python/"
                          version "/Python-" version ".tar.xz"))
      (sha256
       (base32
        "1c8xan2dlsqfq8q82r3mhl72v3knq3qyn71fjq89xikx2smlqg7k"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
;;       258 tests OK.
;;       103 tests failed:
;;          test_bz2 test_distutils test_file test_file2k test_popen2
;;          test_shutil test_signal test_site test_slice test_smtplib
;;          test_smtpnet test_socket test_socketserver test_softspace
;;          test_sort test_sqlite test_ssl test_startfile test_str
;;          test_strftime test_string test_stringprep test_strop test_strptime
;;          test_strtod test_struct test_structmembers test_structseq
;;          test_subprocess test_sunaudiodev test_sundry test_symtable
;;          test_syntax test_sys test_sys_setprofile test_sys_settrace
;;          test_sysconfig test_tarfile test_tcl test_telnetlib test_tempfile
;;          test_textwrap test_thread test_threaded_import
;;          test_threadedtempfile test_threading test_threading_local
;;          test_threadsignals test_time test_timeout test_tk test_tokenize
;;          test_tools test_trace test_traceback test_transformer
;;          test_ttk_guionly test_ttk_textonly test_tuple test_typechecks
;;          test_ucn test_unary test_undocumented_details test_unicode
;;          test_unicode_file test_unicodedata test_univnewlines
;;          test_univnewlines2k test_unpack test_urllib test_urllib2
;;          test_urllib2_localnet test_urllib2net test_urllibnet test_urlparse
;;          test_userdict test_userlist test_userstring test_uu test_uuid
;;          test_wait3 test_wait4 test_warnings test_wave test_weakref
;;          test_weakset test_whichdb test_winreg test_winsound test_with
;;          test_wsgiref test_xdrlib test_xml_etree test_xml_etree_c
;;          test_xmllib test_xmlrpc test_xpickle test_xrange test_zipfile
;;          test_zipfile64 test_zipimport test_zipimport_support test_zlib
;;       31 tests skipped:
;;          test_aepack test_al test_applesingle test_ascii_formatd test_bsddb
;;          test_bsddb185 test_bsddb3 test_cd test_cl test_codecmaps_cn
;;          test_codecmaps_hk test_codecmaps_jp test_codecmaps_kr
;;          test_codecmaps_tw test_ctypes test_curses test_dl test_gdb test_gl
;;          test_imageop test_imgfile test_ioctl test_kqueue
;;          test_linuxaudiodev test_macos test_macostools test_msilib
;;          test_multiprocessing test_ossaudiodev test_pep277
;;          test_scriptpackages
;;       7 skips unexpected on linux2:
;;          test_ascii_formatd test_bsddb test_bsddb3 test_ctypes test_gdb
;;          test_ioctl test_multiprocessing
;;    One of the typical errors:
;;    test_unicode
;;    test test_unicode crashed -- <type 'exceptions.OSError'>: [Errno 2] No such file or directory
       #:test-target "test"
       #:configure-flags
        (let ((bz2 (assoc-ref %build-inputs "bzip2"))
              (gdbm (assoc-ref %build-inputs "gdbm"))
              (openssl (assoc-ref %build-inputs "openssl"))
              (readline (assoc-ref %build-inputs "readline"))
              (zlib (assoc-ref %build-inputs "zlib")))
         (list "--enable-shared"                  ; allow embedding
               (string-append "CPPFLAGS="
                "-I" bz2 "/include "
                "-I" gdbm "/include "
                "-I" openssl "/include "
                "-I" readline "/include "
                "-I" zlib "/include")
               (string-append "LDFLAGS="
                "-L" bz2 "/lib "
                "-L" gdbm "/lib "
                "-L" openssl "/lib "
                "-L" readline "/lib "
                "-L" zlib "/lib")))

        #:modules ((guix build gnu-build-system)
                   (guix build utils)
                   (guix build rpath)
                   (srfi srfi-26))
        #:imported-modules ((guix build gnu-build-system)
                            (guix build utils)
                            (guix build rpath))

        #:phases
        (alist-cons-after
         'strip 'add-lib-to-runpath
         (lambda* (#:key outputs #:allow-other-keys)
           (let* ((out (assoc-ref outputs "out"))
                  (lib (string-append out "/lib")))
             ;; Add LIB to the RUNPATH of all the executables.
             (with-directory-excursion out
               (for-each (cut augment-rpath <> lib)
                         (find-files "bin" ".*")))))
         %standard-phases)))
    (inputs
     `(("bzip2" ,bzip2)
       ("gdbm" ,gdbm)
       ("openssl" ,openssl)
       ("readline" ,readline)
       ("zlib" ,zlib)
       ("patchelf" ,patchelf)))                   ; for (guix build rpath)
    (native-search-paths
     (list (search-path-specification
            (variable "PYTHONPATH")
            (directories '("lib/python2.7/site-packages")))))
    (home-page "http://python.org")
    (synopsis
     "Python, a high-level dynamically-typed programming language")
    (description
     "Python is a remarkably powerful dynamic programming language that
is used in a wide variety of application domains.  Some of its key
distinguishing features include: clear, readable syntax; strong
introspection capabilities; intuitive object orientation; natural
expression of procedural code; full modularity, supporting hierarchical
packages; exception-based error handling; and very high level dynamic
data types.")
    (license psfl)))

(define-public pytz
  (package
    (name "pytz")
    (version "2013b")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "https://launchpad.net/pytz/main/" version
                          "/+download/pytz-" version ".tar.bz2"))
      (sha256
       (base32
        "19giwgfcrg0nr1gdv49qnmf2jb2ilkcfc7qyqvfpz4dp0p64ksv5"))))
    (build-system python-build-system)
    (home-page "https://launchpad.net/pytz")
    (synopsis "The Python timezone library.")
    (description
     "This library allows accurate and cross platform timezone calculations
using Python 2.4 or higher and provides access to the Olson timezone database.")
    (license x11)))

(define-public babel
  (package
    (name "babel")
    (version "0.9.6")
    (source
     (origin
      (method url-fetch)
      (uri (string-append "http://ftp.edgewall.com/pub/babel/Babel-"
                          version ".tar.gz"))
      (sha256
       (base32
        "03vmr54jq5vf3qw6kpdv7cdk7x7i2jhzyf1mawv2gk8zrxg0hfja"))))
    (build-system python-build-system)
    (inputs
     `(("pytz" ,pytz)))
    (home-page "http://babel.edgewall.org/")
    (synopsis
     "Tools for internationalizing Python applications")
    (description
     "Babel is composed of two major parts:
- tools to build and work with gettext message catalogs
- a Python interface to the CLDR (Common Locale Data Repository), providing
access to various locale display names, localized number and date formatting,
etc. ")
    (license bsd-3)))
