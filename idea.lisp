;;;; General ideas:
;;;; - Avoid strings? Reader macros/types instead?
;;;; - Don't require nesting but also allow it
;;;; - Allow gradual specificity

;;; @name is always the name of something
(vpc @my-vpc
     ;; #c reader macro?
     :cidr #c(10.13.0.0/16)

     (subnet @dev-subnet
	     :cidr #c(10.13.0.0/24)))

;;; - upper-case is always substituted?
;;; - or use $thing maybe?
(ec2-instance @spatula-$n :in @my-vpc
	      ;; creates a subnet? automatically called spatula-subnet?
	      ;; or throws an error
	      :private-ip #c(10.13.2.$n)
	      )
     
(want 10 @spatula-$n)

;;; Maybe can leave off -$n if it's unambiguous?
(want 10 @spatula)

;; Rule: any constraint can be specified later (like in). Okay to
;; repeat something you already said

(in @my-vpc @spatula-$n)	;; ok because no conflicst
(in @my-vpc @spatula-$n)	;; still ok because no conflicts

(in @dev-subnet @spatula-$n) ;; throws error because CIDR conflict is unresolvable

;; Basically

;; Can always refer to containing thing with the 'of' function


(ec2-instance @celery :in (of @spatula-$n vpc)
	      :in (of @spatula-$n subnet))


;; Or ... ?
(ec2-instance @celery :in (vpc-of @spatula-$n)
	      :in (subnet-of @spatula-$n))





;;; Rule if you just want the first one use singular form - this may
;;; not be what you want so caveat emptor

(private-ip @celery) ;; returns first private IP
;;; ===> #c(10.13.0.1/32)

;;; plurals always work even if there's logically only one

(private-ips @celery)
;;; ==> (#c(10.13.0.0/32))


;; specifying multiple private ip's
(ec2-instance @frank-$n :in @my-vpc
	      :private-ips (10.13.2.$n 10.13.3.$n)
	      )
