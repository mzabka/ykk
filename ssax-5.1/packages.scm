(define-structure scsh-compat
  (export
   file-size
   open-output-string
   open-input-string
   get-output-string
   error)
  (open scheme
        simple-signals
        posix
        extended-ports)
  (begin
    (define (file-size name)
      (file-info-size (get-file-info name)))
    (define open-output-string make-string-output-port)
    (define (get-output-string port)
      (let ((r (string-output-port-output port)))
        (close-output-port port)
        r))
    (define open-input-string make-string-input-port)))

(define-interface htmlprag-interface
  (export
   html->sxml
   html->shtml
   write-shtml-as-html
   shtml->html))

(define-structure htmlprag
  htmlprag-interface
  (open scheme
        scsh-compat)
  (files htmlprag))

;; Interface definitions first

;; Utilities

(define-interface parser-errors-interface
  (export parser-error))

(define-interface input-parses-interface
  (export peek-next-char
	  assert-curr-char
	  skip-until skip-while
	  next-token next-token-of
	  read-text-line
	  read-string
	  parser-error))

(define-interface ssax-warnings-interface
  (export ssax:warn))

(define-interface assertions-interface
  (export ((assert assure) :syntax)))

(define-interface coutputs-interface
  (export cout cerr nl))

(define-interface ppretty-prints-interface
  (export pp))

(define-interface crementing-interface
  (export inc dec))

(define-interface oleg-utils-interface
  (export any?
	  list-intersperse list-intersperse!
	  list-tail-diff
	  string-rindex
	  substring?
	  string->integer
	  string-split
	  make-char-quotator))

(define-interface control-flows-interface
  (export (when :syntax)
	  (begin0 :syntax)))

(define-interface find-strings-interface
  (export find-string-from-port?))

(define-interface catch-errors-interface
  (export (failed? :syntax)))

(define-interface char-encodings-interface
  (export ucscode->char
	  char-return
	  char-tab
	  char-newline))

;; The Meat

(define-interface sxml-tree-trans-interface
  (export SRV:send-reply
	  post-order pre-post-order replace-range))

(define-interface sxml-to-html-interface
  (export SXML->HTML
	  enattr
	  entag
	  string->goodHTML))

(define-interface sxml-to-html-ext-interface
  (export make-header
	  make-navbar
	  make-footer
	  universal-conversion-rules
	  universal-protected-rules
	  alist-conv-rules))

(define-interface ssax-interface
  (export xml-token? xml-token-kind xml-token-head
	  make-empty-attlist attlist-add
	  attlist-null?
	  attlist-remove-top
	  attlist->alist attlist-fold
	  ssax:uri-string->symbol
	  ssax:skip-internal-dtd
	  ssax:read-pi-body-as-string
	  ssax:reverse-collect-str-drop-ws
	  ssax:read-markup-token
	  ssax:read-cdata-body
	  ssax:read-char-ref
	  ssax:read-attributes
	  ssax:complete-start-tag
	  ssax:read-external-id
	  ssax:read-char-data
	  ((ssax:make-parser ssax:make-pi-parser ssax:make-elem-parser) :syntax)
	  ssax:xml->sxml))

(define-interface sxpath-interface
  (export nodeset?
	  map-union
	  sxpath
          txpath))

;; this list was made by quick glances at
;; sxml-tools.scm.  it is not complete
(define-interface sxml-basic-tools-interface
  (export sxml:attr-list-node
          sxml:attr-as-list
          sxml:attr-list-u
          sxml:aux-list-node
          sxml:aux-as-list
          sxml:empty-element?
          sxml:shallow-normalized?
          sxml:normalized?
          sxml:shallow-minimized?
          sxml:minimized?
          sxml:content
          sxml:text
          sxml:content-raw
          sxml:name
          sxml:node-name
          sxml:attr
          sxml:attr-from-list
          sxml:num-attr
          sxml:change-content!
          sxml:change-content
          sxml:change-attrlist
          sxml:change-attrlist!
          sxml:change-name!
          sxml:change-name
          sxml:add-attr!
          sxml:add-attr
          sxml:change-attr!
          sxml:change-attr
          sxml:set-attr!
          sxml:set-attr
          sxml:add-aux!
          sxml:add-aux
          sxml:squeeze!
          sxml:squeeze
          sxml:clean
          sxml:node-parent
          sxml:add-parents
          sxml:lookup))



;; Structures

;; Utilities

(define-structure define-opt (export (define-opt :syntax))
  (open scheme
	srfi-23)
  (files define-opt))

(define-structure parser-errors-vanilla parser-errors-interface
  (open scheme signals)
  (begin
    (define (parser-error port message . rest)
      (apply error message rest))))

(define (make-input-parses parser-errors-structure)
  (structure input-parses-interface
    (open scheme
	  ascii
	  (subset srfi-13 (string-concatenate-reverse))
	  define-opt
	  crementing
	  char-encodings
	  parser-errors-structure)
    (files input-parse)))

(define input-parses-vanilla (make-input-parses parser-errors-vanilla))

(define-structure assertions assertions-interface
  (open scheme
	big-util)
  (files assert))

(define-structure coutputs coutputs-interface
  (open scheme i/o)
  (files output))

(define-structure ppretty-prints ppretty-prints-interface
  (open scheme pp)
  (begin
    (define pp p)))

(define-structure crementing crementing-interface
  (open scheme)
  (begin
    (define (inc n) (+ n 1))
    (define (dec n) (- n 1))))

(define-structure oleg-utils oleg-utils-interface
  (open scheme
	(subset srfi-13 (string-index-right string-contains string-null?))
	srfi-23
	crementing)
  (files util))

(define-structure char-encodings char-encodings-interface
  (open scheme
	ascii)
  (begin
    (define ucscode->char ascii->char)
    (define char-return (ascii->char 13))
    (define char-tab (ascii->char 9))
    (define char-newline (ascii->char 10))))

(define-structure oleg-string-ports (export with-output-to-string
					    call-with-input-string
					    with-input-from-string)
  (open scheme extended-ports i/o-internal)
  (begin
    (define (with-output-to-string thunk)
      (call-with-string-output-port
       (lambda (port)
	 (call-with-current-output-port port thunk))))
    (define (call-with-input-string string proc)
      (proc (make-string-input-port string)))
    (define with-input-from-string call-with-input-string)))

(define-structure control-flows control-flows-interface
  (open scheme)
  (files control))

(define-structure find-strings find-strings-interface
  (open scheme
	crementing)
  (files look-for-str))

(define-structure catch-errors catch-errors-interface
  (open scheme handle)
  (begin
    (define-syntax failed?
      (syntax-rules ()
	((failed? stmts ...)
	 (thunk-failed? (lambda () stmts ...)))))
    (define (thunk-failed? thunk)
      (call-with-current-continuation
       (lambda (return)
	 (with-handler
	  (lambda (condition more)
	    (return #t))
	  (lambda ()
	    (thunk)
	    #f)))))))


;; The Meat

(define-structure sxml-tree-trans sxml-tree-trans-interface
  (open scheme
	assertions
	srfi-11 ; LET*-VALUES
	srfi-23) ; ERROR
  (files "SXML-tree-trans.scm"))
	
(define-structure sxml-to-html sxml-to-html-interface
  (open scheme
	coutputs assertions
	oleg-utils
	sxml-tree-trans)
  (files "SXML-to-HTML.scm"))

(define-structure sxml-to-html-ext sxml-to-html-ext-interface
  (open scheme
        scsh-compat
	(subset srfi-13 (string-split))
	srfi-23
	oleg-utils
	coutputs
	assertions
	crementing
	sxml-to-html
	sxml-tree-trans)
  (begin
    (define OS:file-length file-size))
  (files "SXML-to-HTML-ext.scm"))

(define (make-ssax input-parses-structure ssax-warnings-structure)
  (structure ssax-interface
	     (open scheme
		   oleg-utils control-flows find-strings
		   ascii
		   assertions
		   coutputs catch-errors
		   oleg-string-ports
		   input-parses-structure
		   ssax-warnings-structure
		   char-encodings
		   crementing
		   (subset srfi-1 (cons*))
		   srfi-6 ; OPEN-INPUT-STRING
		   srfi-11 ; LET-VALUES
		   (subset srfi-13 (string-index
				    string-null?
				    string-concatenate-reverse/shared
				    string-concatenate/shared))
		   srfi-23
		   ppretty-prints)
	     (files "SSAX-code.scm")))

(define-structure ssax-warnings-vanilla ssax-warnings-interface
  (open scheme
	coutputs)
  (files ssax-warn-vanilla))

(define ssax-vanilla (make-ssax input-parses-vanilla
				ssax-warnings-vanilla))

(define-structure sxml-basic-tools
  (compound-interface sxml-basic-tools-interface
                      sxpath-interface)
  (open scheme
        assertions
        coutputs
        simple-signals
        oleg-utils
        crementing
        srfi-1
        srfi-2
        extended-ports
        srfi-13
        pp)
  (begin
    (define pp p)
    
    (define (call-with-input-string str proc)
      (proc (make-string-input-port str)))

    (define-syntax define-macro
      (lambda (e r c)
        (let* ((pattern (cadr e))
               (name (if (pair? pattern)
                         (car pattern)
                         pattern))
               (lamb (if (pair? pattern)
                         (cons 'lambda (cons (cdr pattern) (cddr e)))
                         (caddr e))))
          `(define-syntax ,name
             (lambda (e r c)
               (let ((args (cdr e)))
                 (apply ,lamb args))))))))
  (files "sxml-tools/sxpathlib.scm"
         "sxml-tools/xpath-parser.scm"
         "sxml-tools/sxml-tools.scm"
         "sxml-tools/sxpath-ext.scm"
         "sxml-tools/sxpath.scm"
         "sxml-tools/txpath.scm"))
