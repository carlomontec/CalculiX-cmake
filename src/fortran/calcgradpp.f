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
      subroutine calcgradpp(ne,lakon,ipnei,ppfa,area,xxn,gradpp,neifa)
!
!     calculation of the gradient of p' at the center
!     of the elements from the p' values at the neighboring
!     faces
!
      implicit none
!
      character*8 lakon(*)
!
      integer ne,ipnei(*),neifa(*),i,j,k,indexf,ifa
!
      real*8 ppfa(*),area(*),xxn(3,*),gradpp(3,*)
!
      do i=1,ne
         if(lakon(i)(1:1).ne.'F') cycle
         indexf=ipnei(i)
         if(lakon(i)(4:4).eq.'8') then
            do j=1,6
               indexf=indexf+1
               ifa=neifa(indexf)
               do k=1,3
                  gradpp(k,i)=gradpp(k,i)+
     &                 ppfa(ifa)*area(ifa)*xxn(k,indexf)
               enddo
            enddo
         endif
      enddo
!            
      return
      end
