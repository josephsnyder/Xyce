include(ExternalProject)
find_package(Git)
# Find specific folder locations

# Version 3.5.0 required for Trilinos version
# https://github.com/trilinos/Trilinos/issues/480
if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set( POINTER_SIZE  "64" )
else()
  set( POINTER_SIZE "32" )
endif()

set(BLAS_DEPS)
set(CMAKE_LIBRARY_PATH ${CMAKE_CURRENT_BINARY_DIR}/install)

if(DEFINED ENV{MKLROOT})
  set(BLA_VENDOR Intel10_64lp)
endif()

# Lifted from KWIVER
# Don't force a build type in mutli-configuration platforms
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
endif()

find_package(LAPACK 3.5.0)
if(NOT LAPACK_LIBRARIES)
  if(WIN32)
    message("No system libraries found. Download of LAPACK will occur at build time")
    ExternalProject_Add(LAPACKD
    URL "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/Win${POINTER_SIZE}/liblapack.lib"
    DOWNLOAD_NO_EXTRACT ON
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/../liblapack.lib ${CMAKE_LIBRARY_PATH}
    )
    ExternalProject_Add(LAPACKR
    URL "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/Win${POINTER_SIZE}/liblapack.dll"
    DOWNLOAD_NO_EXTRACT ON
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/../liblapack.dll ${CMAKE_LIBRARY_PATH}
    )
    list(APPEND BLAS_DEPS
      LAPACKD
      LAPACKR
    )
    set(LAPACK_LIBRARIES ${CMAKE_LIBRARY_PATH}/liblapack.lib)
  endif()
endif()

find_package(BLAS 3.5.0)
if(NOT BLAS_LIBRARIES)
  if(WIN32)
    message("No system libraries found. Download of BLAS will occur at build time")

    ExternalProject_Add(BLASD
    URL "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/Win${POINTER_SIZE}/libblas.lib"
    DOWNLOAD_NO_EXTRACT ON
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/../libblas.lib ${CMAKE_LIBRARY_PATH}
    )
    ExternalProject_Add(BLASR
    URL "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/Win${POINTER_SIZE}/libblas.dll"
    DOWNLOAD_NO_EXTRACT ON
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/../libblas.dll ${CMAKE_LIBRARY_PATH}
    )
    list(APPEND BLAS_DEPS
      BLASD
      BLASR
    )
    set(BLAS_LIBRARIES ${CMAKE_LIBRARY_PATH}/libblas.lib)
  endif()
endif()

set(DEPENDENCIES)
set(TRILINOS_SERIAL_ARGS)
set(TRILINOS_PARALLEL_ARGS)
set(DEFAULT_ARGS)
list(APPEND DEFAULT_ARGS
  -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/install
  -DCMAKE_BUILD_TYPE=$<CONFIG>
  -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/install
  -DGIT_EXEC=${GIT_EXECUTABLE}
  -DCMAKE_LIBRARY_PATH=${CMAKE_LIBRARY_PATH}
  # -DCMAKE_CONFIGURATION_TYPES:STRING=${CMAKE_SS_CONF_TYPES}
  -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS}
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
  -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
)

set(Xyce_ARGS ${DEFAULT_ARGS} -DXyce_USE_SUPERBUILD=OFF)

list (APPEND TRILINOS_PARALLEL_ARGS
  ${DEFAULT_ARGS}
  -DTrilinos_ENABLE_NOX=ON
  -DNOX_ENABLE_LOCA=ON
  -DTrilinos_ENABLE_EpetraExt=ON
  -DEpetraExt_BUILD_BTF=ON
  -DEpetraExt_BUILD_EXPERIMENTAL=ON
  -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON
  -DTrilinos_ENABLE_TrilinosCouplings=ON
  -DTrilinos_ENABLE_Ifpack=ON
  -DTrilinos_ENABLE_ShyLU=ON
  -DTrilinos_ENABLE_Isorropia=OFF
  -DTrilinos_ENABLE_AztecOO=ON
  -DTrilinos_ENABLE_Belos=ON
  -DTrilinos_ENABLE_Teuchos=ON
  -DTeuchos_ENABLE_COMPLEX=ON
  -DTrilinos_ENABLE_Amesos=ON
  -DAmesos_ENABLE_KLU=ON
  -DTrilinos_ENABLE_Sacado=ON
  -DTrilinos_ENABLE_Kokkos=OFF
  -DTrilinos_ENABLE_Zoltan=ON
  -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF
  -DTrilinos_ENABLE_CXX11=ON
  -DTPL_ENABLE_AMD=ON
  -DAMD_LIBRARY_DIRS=${AMD_LIB_PATH}
  -DTPL_AMD_INCLUDE_DIRS=${AMD_PATH}
  -DTPL_ENABLE_BLAS=ON
  -DTPL_BLAS_LIBRARIES=${BLAS_LIBRARIES}
  -DTPL_ENABLE_LAPACK=ON
  -DTPL_LAPACK_LIBRARIES=${LAPACK_LIBRARIES}
  -DTPL_ENABLE_MPI=ON
  -DTPL_ENABLE_DLlib:BOOL=OFF
)
list (APPEND TRILINOS_SERIAL_ARGS
  ${DEFAULT_ARGS}
  -DTrilinos_ENABLE_NOX=ON
    -DNOX_ENABLE_LOCA=ON
  -DTrilinos_ENABLE_EpetraExt=ON
    -DEpetraExt_BUILD_BTF=ON
    -DEpetraExt_BUILD_EXPERIMENTAL=ON
    -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON
  -DTrilinos_ENABLE_TrilinosCouplings=ON
  -DTrilinos_ENABLE_Ifpack=ON
  -DTrilinos_ENABLE_Isorropia=OFF
  -DTrilinos_ENABLE_AztecOO=ON
  -DTrilinos_ENABLE_Belos=ON
  -DTrilinos_ENABLE_Teuchos=ON
    -DTeuchos_ENABLE_COMPLEX=ON
  -DTrilinos_ENABLE_Amesos=ON
    -DAmesos_ENABLE_KLU=ON
  -DTrilinos_ENABLE_Sacado=ON
  -DTrilinos_ENABLE_Kokkos=OFF
  -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF
  -DTrilinos_ENABLE_CXX11=ON
  -DTPL_ENABLE_AMD=ON
  -DAMD_LIBRARY_DIRS=${AMD_LIB_PATH}
  -DTPL_AMD_INCLUDE_DIRS=${AMD_PATH}
  -DTPL_ENABLE_BLAS=ON
  -DTPL_BLAS_LIBRARIES=${BLAS_LIBRARIES}
  -DTPL_ENABLE_LAPACK=ON
  -DTPL_LAPACK_LIBRARIES=${LAPACK_LIBRARIES}
  -DTPL_ENABLE_MPI=OFF
  -DTPL_ENABLE_DLlib:BOOL=OFF
)

if(WIN32)
  list (APPEND TRILINOS_SERIAL_ARGS -DTPL_ENABLE_Pthread=OFF)
endif()

set(Xyce_TRILINOS_ARGS ${TRILINOS_SERIAL_ARGS})
option(Xyce_USE_PARALLEL_ARGS OFF "Use the parallel args for building Trilinos?")
if(Xyce_USE_PARALLEL_ARGS)
  set(Xyce_TRILINOS_ARGS ${TRILINOS_PARALLEL_ARGS})
endif()

if(WIN32)
  list(APPEND DEPENDENCIES "winflexbison")
  ExternalProject_Add(winflexbison
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install
    GIT_REPOSITORY https://github.com/lexxmark/winflexbison.git
    GIT_TAG v2.5.22
    GIT_SHALLOW True
    CMAKE_ARGS ${DEFAULT_ARGS}
  )

endif(WIN32)

option(Xyce_USE_FFTW ON "Use FFTW")
if(Xyce_USE_FFTW)
  find_library(fftw
    names libfftw3-3
    PATH_SUFFIXES "lib" "lib64"
  )
  if(WIN32)
    if(NOT fftw_LIBRARIES)
      list(APPEND DEPENDENCIES FFTW)
      ExternalProject_Add(FFTW
      URL "ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll${POINTER_SIZE}.zip"
      BUILD_IN_SOURCE TRUE
      CONFIGURE_COMMAND ""
      BUILD_COMMAND lib /def:libfftw3f-3.def && lib /def:libfftw3-3.def && lib /def:libfftw3l-3.def
      INSTALL_COMMAND ""
      )
      ExternalProject_Get_property(FFTW SOURCE_DIR)
      list(APPEND CMAKE_PREFIX_PATH ${SOURCE_DIR})
      list(APPEND Xyce_ARGS -DFFTW_ROOT=${SOURCE_DIR})
    endif()
  endif()
endif()


list(APPEND DEPENDENCIES "suitesparse")
ExternalProject_Add(suitesparse
  INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install
  GIT_REPOSITORY https://github.com/DrTimothyAldenDavis/SuiteSparse.git
  GIT_TAG v5.6.0
  GIT_SHALLOW True
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Patch_suitesparse.cmake <SOURCE_DIR>/CMakeLists.txt
  CMAKE_ARGS ${DEFAULT_ARGS}
)

list(APPEND DEPENDENCIES "Trilinos")
ExternalProject_Add(Trilinos
  DEPENDS suitesparse ${BLAS_DEPS}
  GIT_REPOSITORY https://github.com/Trilinos/Trilinos
  GIT_TAG trilinos-release-12-12-1
  GIT_SHALLOW True
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Patch_EpetraExt_Transform_Composite.h <SOURCE_DIR>/packages/epetraext/src/transform/EpetraExt_Transform_Composite.h
  CMAKE_ARGS ${Xyce_TRILINOS_ARGS}
)

ExternalProject_Add (Xyce
  DEPENDS ${DEPENDENCIES}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
  CMAKE_ARGS ${Xyce_ARGS}
  INSTALL_COMMAND ""
)