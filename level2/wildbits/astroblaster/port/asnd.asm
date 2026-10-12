                    nam asnd
                    use defsfile
                    mod DescriptorEnd,DescriptorName,Devic+Objct,ReEnt+1,ManagerName,DriverName
                    fcb WRITE.
                    fcb HW.Page
                    fdb $FF9A
                    fcb InitialEnd-*-1
                    fcb DT.SCF
                    fcb 0,1,0,0,0,0,0,24
                    fcb 0,0,0,0,0,0,0,0,0,0,0
                    fcb 0,0
                    fdb 0
                    fcb 0,0,80,24
InitialEnd          equ *
DescriptorName      fcs /asnd/
ManagerName         fcs /SCF/
DriverName          fcs /AstroSnd/
                    emod
DescriptorEnd       equ *
                    end
