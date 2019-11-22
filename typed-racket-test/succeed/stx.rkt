#lang typed/racket

;; Test that the typed/syntax/stx library can be used

(require typed/syntax/stx
         typed/rackunit)

(check-true (stx-null? null))
(check-true (stx-null? #'()))
(check-false (stx-null? #'(a)))

(check-true (stx-pair? (cons #'a #'b)))
(check-true (stx-pair? #'(a . b)))

(check-true (stx-list? #'(a b c d)))
(check-false (stx-list? #'a))

(ann (stx->list #'(a b c d)) (Listof (Syntaxof Symbol)))
(ann (syntax-e (car (stx->list #'(a b c d)))) Symbol)
(ann (stx->list (list #'a #'b)) (Listof (Syntaxof Symbol)))
(ann (stx->list (list 'a 'b)) (Listof Symbol))
(ann (add1 (car (stx->list '(1 2 3)))) Positive-Index)
(ann (stx->list #'(a b . (c d))) (Listof (Syntaxof Symbol)))
(ann (stx->list (cons #'a #'(b . (c d)))) (Listof (Syntaxof Symbol)))
;; Make sure case-> type doesn't have intersecting domains with
;; incompatible result types
(ann (assert (stx->list (ann #'(a b c) (Syntaxof Any))))
     (Listof (Syntaxof Any)))

(ann (stx-car #'(a b)) (Syntaxof 'a))
(ann (stx-cdr #'(a b)) (List (Syntaxof 'b)))

(ann (stx-map (λ: ([id : Identifier]) (free-identifier=? id #'a))
              #'(a b c d))
     (Listof Boolean))
(ann (stx-map (λ: ([id : Symbol]) (symbol=? id 'a))
              '(a b c d))
     (Listof Boolean))
(ann (stx-map (λ: ([id : Identifier]) (free-identifier=? id #'a))
              (cons #'a #'(b . (c d))))
     (Listof Boolean))
(ann (stx-map (λ: ([x : (Syntaxof Real)] [y : (Syntaxof Real)])
                (+ (syntax-e x) (syntax-e y)))
              #'(1 2 3)
              #'(1 2 3))
     (Listof Real))
(ann (stx-map +
              '(1 2 3)
              '(1 2 3))
     (Listof Real))
(ann (stx-map (λ: ([x : (Syntaxof Real)] [y : (Syntaxof Real)])
                (+ (syntax-e x) (syntax-e y)))
              #'(1 . (2 3))
              (cons #'1 #'(2 . (3))))
     (Listof Real))

(module-or-top-identifier=? #'a #'b)

(ann (let* ([ xs : (Listof Syntax) (list #'1 #'2)]
            [ id : (-> Syntax Syntax) (λ (x) x)]
            [ x  : (Syntaxof Any) #`(#,@(map id xs) #'foo)]
            )
       x)
     (Syntaxof Any))
