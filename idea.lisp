;;;; General ideas:
;;;; - Avoid strings? Reader macros/types instead?
;;;; - Don't require nesting but also allow it
;;;; - Allow gradual specificity
;;;; - Need some way to do high level templating so you can stamp out
;;;;   multiple copies

;;; Prefixes everything; need params too
(namespace @my-ns
	   :params ((cluster-size 10)))


;;; also a convention if you use / it automatically adds to containing
;;; thing. Namespace is special case; it's auto-added.

;;; @name is always the name of something
(vpc @my-vpc
     ;; #c reader macro?
     :cidr #c(10.13.0.0/16)

     (subnet @dev-subnet
	     :cidr #c(10.13.0.0/24))

     :tag some-tag)


;; Or you could do:

(vpc @my-ns/@my-vpc
     ;; blah blah blah
     )

;;; tags can be k/v or not
(tag @my-vpc '(another-tag 23)
             yet-another-tag)


;;; this is really just a fragment/template, not a complete object -
;;; different naming convention?
(ebs-volume @basic-volume "/dev/sda" :size 200)

;;; - upper-case is always substituted?
;;; - or use $thing maybe?
(ec2-instance @spatula-$n :in @my-vpc
	      ;; creates a subnet? automatically called spatula-subnet?
	      ;; or throws an error
	      :private-ip #c(10.13.2.$n)
	      :volume @basic-volume
	      )

;;; or you could do (implicit :in)
;;; name (for later reference) is still @spatula-$n
(ec2-instance @my-vpc/@spatula-$n)
(ec2-instance @my-vpc/@dev-subnet/@spatula-$n)
	      

(want $cluster-size @spatula-$n)

;;; Maybe can leave off -$n if it's unambiguous?
(want $cluster-size @spatula)

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


