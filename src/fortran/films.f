!
!     CalculiX - A 3-dimensional finite element program
!              Copyright (C) 1998-2014 Guido Dhondt
!
!     This program is free software; you can redistribute it and/or
!     modify it under the terms of the GNU General Public License as
!     published by the Free Software Foundation(version 2);
!     
!
!     This program is distributed in the hope that it will be useful,
!     but WITHOUT ANY WARRANTY; without even the implied warranty of 
!     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
!     GNU General Public License for more details.
!
!     You should have received a copy of the GNU General Public License
!     along with this program; if not, write to the Free Software
!     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
!
      subroutine films(inpc,textpart,set,istartset,iendset,
     &  ialset,nset,nelemload,sideload,xload,nload,nload_,
     &  ielmat,ntmat_,iamload,amname,nam,lakon,ne,flow_flag,
     &  istep,istat,n,iline,ipol,inl,ipoinp,inp,nam_,namtot_,namta,amta,
     &  ipoinpc,mi)
!
!     reading the input deck: *FILM
!
      implicit none
!
      logical flow_flag
!
      character*1 inpc(*)
      character*8 lakon(*)
      character*20 sideload(*),label
      character*80 amname(*),amplitude
      character*81 set(*),elset
      character*132 textpart(16)
!
      integer istartset(*),iendset(*),ialset(*),nelemload(2,*),mi(*),
     &  ielmat(mi(3),*),nset,nload,nload_,ntmat_,istep,istat,n,i,
     &  j,l,key,iload,
     &  iamload(2,*),nam,iamptemp,ipos,ne,node,iampfilm,iline,ipol,inl,
     &  ipoinp(2,*),inp(3,*),nam_,namtot,namtot_,namta(3,*),idelay1,
     &  idelay2,ipoinpc(0:*)
!
      real*8 xload(2,*),xmagfilm,xmagtemp,amta(2,*)
!
      iamptemp=0
      iampfilm=0
      idelay1=0
      idelay2=0
!
      if(istep.lt.1) then
         write(*,*) '*ERROR in films: *FILM should only be used'
         write(*,*) '  within a STEP'
         stop
      endif
!
      do i=2,n
         if((textpart(i)(1:6).eq.'OP=NEW').and.(.not.flow_flag)) then
            do j=1,nload
               if(sideload(j)(1:1).eq.'F') then
                  xload(1,j)=0.d0
               endif
            enddo
         elseif(textpart(i)(1:10).eq.'AMPLITUDE=') then
            read(textpart(i)(11:90),'(a80)') amplitude
            do j=nam,1,-1
               if(amname(j).eq.amplitude) then
                  iamptemp=j
                  exit
               endif
            enddo
            if(j.eq.0) then
               write(*,*)'*ERROR in films: nonexistent amplitude'
               write(*,*) '  '
               call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
               stop
            endif
            iamptemp=j
         elseif(textpart(i)(1:10).eq.'TIMEDELAY=') THEN
            if(idelay1.ne.0) then
               write(*,*) '*ERROR in films: the parameter TIME DELAY'
               write(*,*) '       is used twice in the same keyword'
               write(*,*) '       '
               call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
               stop
            else
               idelay1=1
            endif
            nam=nam+1
            if(nam.gt.nam_) then
               write(*,*) '*ERROR in films: increase nam_'
               stop
            endif
            amname(nam)='
     &                                 '
            if(iamptemp.eq.0) then
               write(*,*) '*ERROR in films: time delay must be'
               write(*,*) '       preceded by the amplitude parameter'
               stop
            endif
            namta(3,nam)=sign(iamptemp,namta(3,iamptemp))
            iamptemp=nam
            if(nam.eq.1) then
               namtot=0
            else
               namtot=namta(2,nam-1)
            endif
            namtot=namtot+1
            if(namtot.gt.namtot_) then
               write(*,*) '*ERROR films: increase namtot_'
               stop
            endif
            namta(1,nam)=namtot
            namta(2,nam)=namtot
            read(textpart(i)(11:30),'(f20.0)',iostat=istat) 
     &           amta(1,namtot)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
         elseif(textpart(i)(1:14).eq.'FILMAMPLITUDE=') then
            read(textpart(i)(15:94),'(a80)') amplitude
            do j=nam,1,-1
               if(amname(j).eq.amplitude) then
                  iampfilm=j
                  exit
               endif
            enddo
            if(j.eq.0) then
               write(*,*)'*ERROR in films: nonexistent amplitude'
               write(*,*) '  '
               call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
               stop
            endif
            iampfilm=j
         elseif(textpart(i)(1:14).eq.'FILMTIMEDELAY=') THEN
            if(idelay2.ne.0) then
               write(*,*) '*ERROR in films: the parameter FILM TIME'
               write(*,*) '       DELAY is used twice in the same'
               write(*,*) '       keyword; '
               call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
               stop
            else
               idelay2=1
            endif
            nam=nam+1
            if(nam.gt.nam_) then
               write(*,*) '*ERROR in films: increase nam_'
               stop
            endif
            amname(nam)='
     &                                 '
            if(iampfilm.eq.0) then
               write(*,*) '*ERROR in films: film time delay must be'
               write(*,*) '       preceded by the film amplitude'
               write(*,*) '       parameter'
               stop
            endif
            namta(3,nam)=sign(iampfilm,namta(3,iampfilm))
            iampfilm=nam
            if(nam.eq.1) then
               namtot=0
            else
               namtot=namta(2,nam-1)
            endif
            namtot=namtot+1
            if(namtot.gt.namtot_) then
               write(*,*) '*ERROR films: increase namtot_'
               stop
            endif
            namta(1,nam)=namtot
            namta(2,nam)=namtot
            read(textpart(i)(15:34),'(f20.0)',iostat=istat) 
     &           amta(1,namtot)
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
         else
            write(*,*) 
     &        '*WARNING in films: parameter not recognized:'
            write(*,*) '         ',
     &                 textpart(i)(1:index(textpart(i),' ')-1)
            call inputwarning(inpc,ipoinpc,iline,
     &"*FILM%")
         endif
      enddo
!
      do
         call getnewline(inpc,textpart,istat,n,key,iline,ipol,inl,
     &        ipoinp,inp,ipoinpc)
         if((istat.lt.0).or.(key.eq.1)) return
!
         read(textpart(2)(1:20),'(a20)',iostat=istat) label
!
!        compatibility with ABAQUS for shells
!
         if(label(2:4).eq.'NEG') label(2:4)='1  '
         if(label(2:4).eq.'POS') label(2:4)='2  '
         if(label(2:2).eq.'N') label(2:2)='5'
         if(label(2:2).eq.'P') label(2:2)='6'
!
!        reference temperature and film coefficient
!        (for non uniform loading: use user routine film.f)
!
         if((label(3:4).ne.'NU').and.(label(3:4).ne.'FC')) then
            read(textpart(3)(1:20),'(f20.0)',iostat=istat) xmagtemp
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
            read(textpart(4)(1:20),'(f20.0)',iostat=istat) xmagfilm
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
            node=0
!
!        for forced convection: reference node and, optionally,
!        a film coefficient (else use user routine film.f)
!
         elseif(label(3:4).eq.'FC') then
            read(textpart(3)(1:10),'(i10)',iostat=istat) node
            if(istat.gt.0) call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
            xmagtemp=0.d0
            read(textpart(4)(1:20),'(f20.0)',iostat=istat) xmagfilm
            if(istat.gt.0) xmagfilm=-1.d0
         endif
         if(((label(1:2).ne.'F1').and.(label(1:2).ne.'F2').and.
     &       (label(1:2).ne.'F3').and.(label(1:2).ne.'F4').and.
     &       (label(1:2).ne.'F5').and.(label(1:2).ne.'F6')).or.
     &      ((label(3:4).ne.'  ').and.(label(3:4).ne.'NU').and.
     &       (label(3:4).ne.'FC'))) then
            call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
         endif
!
         read(textpart(1)(1:10),'(i10)',iostat=istat) l
         if(istat.eq.0) then
            if(l.gt.ne) then
               write(*,*) '*ERROR in films: element ',l
               write(*,*) '       is not defined'
               stop
            endif
!
            if((lakon(l)(1:2).eq.'CP').or.
     &           (lakon(l)(2:2).eq.'A').or.
     &           (lakon(l)(7:7).eq.'E').or.
     &           (lakon(l)(7:7).eq.'S').or.
     &           (lakon(l)(7:7).eq.'A')) then
               if(label(1:2).eq.'F1') then
                  label(1:2)='F3'
               elseif(label(1:2).eq.'F2') then
                  label(1:2)='F4'
               elseif(label(1:2).eq.'F3') then
                  label(1:2)='F5'
               elseif(label(1:2).eq.'F4') then
                  label(1:2)='F6'
               elseif(label(1:2).eq.'F5') then
                  label(1:2)='F1'
               elseif(label(1:2).eq.'F6') then
                  label(1:2)='F2'
               endif
            endif
            call loadaddt(l,label,xmagfilm,xmagtemp,nelemload,sideload,
     &           xload,nload,nload_,iamload,
     &           iamptemp,iampfilm,nam,node,iload)
         else
            read(textpart(1)(1:80),'(a80)',iostat=istat) elset
            elset(81:81)=' '
            ipos=index(elset,' ')
            elset(ipos:ipos)='E'
            do i=1,nset
               if(set(i).eq.elset) exit
            enddo
            if(i.gt.nset) then
               elset(ipos:ipos)=' '
               write(*,*) '*ERROR in films: element set ',elset
               write(*,*) '       has not yet been defined. '
               call inputerror(inpc,ipoinpc,iline,
     &"*FILM%")
               stop
            endif
!
            l=ialset(istartset(i))
            if((lakon(l)(1:2).eq.'CP').or.
     &           (lakon(l)(2:2).eq.'A').or.
     &           (lakon(l)(7:7).eq.'E').or.
     &           (lakon(l)(7:7).eq.'S').or.
     &           (lakon(l)(7:7).eq.'A')) then
               if(label(1:2).eq.'F1') then
                  label(1:2)='F3'
               elseif(label(1:2).eq.'F2') then
                  label(1:2)='F4'
               elseif(label(1:2).eq.'F3') then
                  label(1:2)='F5'
               elseif(label(1:2).eq.'F4') then
                  label(1:2)='F6'
               elseif(label(1:2).eq.'F5') then
                  label(1:2)='F1'
               elseif(label(1:2).eq.'F6') then
                  label(1:2)='F2'
               endif
            endif
!
            do j=istartset(i),iendset(i)
               if(ialset(j).gt.0) then
                  l=ialset(j)
                  call loadaddt(l,label,xmagfilm,xmagtemp,nelemload,
     &                 sideload,xload,nload,nload_,iamload,
     &                 iamptemp,iampfilm,nam,node,iload)
               else
                  l=ialset(j-2)
                  do
                     l=l-ialset(j)
                     if(l.ge.ialset(j-1)) exit
                     call loadaddt(l,label,xmagfilm,xmagtemp,nelemload,
     &                    sideload,xload,nload,nload_,iamload,
     &                    iamptemp,iampfilm,nam,node,iload)
                  enddo
               endif
            enddo
         endif
      enddo
!
      return
      end

