      implicit none
      integer ns,nt
      double precision, allocatable :: source(:,:),targ(:,:)
      double complex, allocatable :: charge(:,:),dipstr(:,:)
      double complex, allocatable :: dipvec(:,:,:)
      double complex, allocatable :: pot(:,:),pottarg(:,:)
      double complex, allocatable :: grad(:,:,:),gradtarg(:,:,:)

      double precision t1,t2
      double precision, allocatable :: timings(:,:)

      double precision eps
      double complex eye,zk
      integer i,j,k,ntest,nd,idim,icase,ncases
      integer ifcharge,ifdipole,ifpgh,ifpghtarg
      double precision err,hkrand
      

      data eye/(0.0d0,1.0d0)/

c
cc      initialize printing routine
c
      call prini(6,13)



      zk = 1.2d0 + eye*0.02d0

      ns = 20000
      nt = 20000
      allocate(source(3,ns),targ(3,nt))

      do i=1,ns
        source(1,i) = hkrand(0)**2
        source(2,i) = hkrand(0)**2
        source(3,i) = hkrand(0)**2
      enddo

      do i=1,nt
        targ(1,i) = hkrand(0)
        targ(2,i) = hkrand(0)
        targ(3,i) = hkrand(0)
      enddo

      ncases = 8

      allocate(timings(2,ncases))

      do icase = 1,ncases

         
        nd = 2**(icase-1)
        call prinf('nd=*',nd,1)

        allocate(charge(nd,ns),dipstr(nd,ns),dipvec(nd,3,ns))
        allocate(pot(nd,ns))
        allocate(grad(nd,3,ns))

        allocate(pottarg(nd,nt))
        allocate(gradtarg(nd,3,nt))


        do i=1,ns
          do idim=1,nd
            charge(idim,i) = hkrand(0) + eye*hkrand(0)
            dipstr(idim,i) = hkrand(0) + eye*hkrand(0)

            dipvec(idim,1,i) = hkrand(0)
            dipvec(idim,2,i) = hkrand(0)
            dipvec(idim,3,i) = hkrand(0)

            pot(idim,i) = 0
            grad(idim,1,i) = 0
            grad(idim,2,i) = 0
            grad(idim,3,i) = 0
          enddo
        enddo

c
cc      generate targets uniformly in the unit cube
c
        do i=1,nt
          do idim=1,nd
            pottarg(idim,i) = 0
            gradtarg(idim,1,i) = 0
            gradtarg(idim,2,i) = 0
            gradtarg(idim,3,i) = 0 
          enddo
        enddo

        eps = 0.5d-6

        call cpu_time(t1)
        call hfmm3dpartstoscp_vec(nd,eps,zk,ns,source,charge,
     1      pot)
        call cpu_time(t2)

        timings(1,icase) = t2-t1

        call cpu_time(t1)
        call hfmm3dpartstostcp_vec(nd,eps,zk,ns,source,charge,pot,
     1       nt,targ,pottarg)
        call cpu_time(t2)

        timings(2,icase) = t2-t1
        deallocate(charge,dipstr,dipvec,pot,grad,pottarg,gradtarg)
      enddo

      call prin2('timings=*',timings,2*ncases)

      open(unit=33,file='vec_speedup.txt',access='append')
 1100 format(2x,i3,2(2x,e11.5))      
      do i=1,ncases
        write(33,1100) 2**(i-1),timings(1,i),timings(2,i)
      enddo
      close(33)

      stop
      end
c----------------------------------------------------------
