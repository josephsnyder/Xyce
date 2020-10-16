cmake_minimum_required(VERSION 3.10 FATAL_ERROR)


project(Xyce_Superbuild VERSION 8.0.0 LANGUAGES CXX C)
option(Xyce_USE_SUPERBUILD "Use superbuild to install Trilinos?"  )
if(Xyce_USE_SUPERBUILD)

  find_package(Git)
  # Find specific folder locations

  # Version 3.5.0 required for Trilinos version
  # https://github.com/trilinos/Trilinos/issues/480
  if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
    set( DESIRED_BYTE_ORDER "Win64" )
  else()
    set( DESIRED_BYTE_ORDER "Win32" )
  endif()
  find_package(BLAS 3.5.0)
  if(NOT BLAS_LIBRARIES)
    set(BLAS_LIBRARY_LIST "")
    message("No system libraries found. Downloading")
    file(DOWNLOAD
      "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/${DESIRED_BYTE_ORDER}/libblas.lib"
      ${CMAKE_CURRENT_BINARY_DIR}/install/libblas.lib
    )
    file(DOWNLOAD
    "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/${DESIRED_BYTE_ORDER}/libblas.dll"
    ${CMAKE_CURRENT_BINARY_DIR}/install/libblas.dll
    )
    list(APPEND BLAS_LIBRARY_LIST
      ${CMAKE_CURRENT_BINARY_DIR}/install/libblas.lib
      ${CMAKE_CURRENT_BINARY_DIR}/install/libblas.dll
    )
    set(BLAS_LIBRARIES "${BLAS_LIBRARY_LIST}" CACHE STRING "List of BLAS libraries")
  endif()

  find_package(LAPACK 3.5.0)
  if(NOT LAPACK_LIBRARIES)
    set(LAPACK_LIBRARY_LIST)
    message("No system libraries found. Downloading")
    file(DOWNLOAD
      "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/${DESIRED_BYTE_ORDER}/liblapack.lib"
      ${CMAKE_CURRENT_BINARY_DIR}/install/liblapack.lib
    )
    file(DOWNLOAD
    "http://icl.cs.utk.edu/lapack-for-windows/libraries/VisualStudio/3.5.0/Dynamic-MINGW/${DESIRED_BYTE_ORDER}/liblapack.dll"
    ${CMAKE_CURRENT_BINARY_DIR}/install/liblapack.dll
    )
    list(APPEND LAPACK_LIBRARY_LIST
      ${CMAKE_CURRENT_BINARY_DIR}/install/liblapack.lib
      ${CMAKE_CURRENT_BINARY_DIR}/install/liblapack.dll
    )
    message("Using LAPACK_LIBRARIES: ${LAPACK_LIBRARY_LIST}")
    set(LAPACK_LIBRARIES ${LAPACK_LIBRARY_LIST} CACHE STRING "List of LAPACK libraries")
endif()
  include(ExternalProject)
  set(DEPENDENCIES)
  set(TRILINOS_SERIAL_ARGS)
  set(TRILINOS_PARALLEL_ARGS)
  set(DEFAULT_ARGS)
  list(APPEND DEFAULT_ARGS
    -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/install
    -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/install
    -DGIT_EXEC=${GIT_EXECUTABLE}
  )
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
     -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/install
     -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/install
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

  list(APPEND DEPENDENCIES "suitesparse")
  ExternalProject_Add(suitesparse
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install
    GIT_REPOSITORY https://github.com/DrTimothyAldenDavis/SuiteSparse.git
    GIT_TAG v5.6.0
    GIT_SHALLOW True
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Patch_suitesparse.cmake <SOURCE_DIR>/CMakeLists.txt
    CMAKE_ARGS ${DEFAULT_ARGS}
  )
  #list(APPEND DEPENDENCIES "boost")
  #include(cmake/External_Boost)

  list(APPEND DEPENDENCIES "Trilinos")
  ExternalProject_Add(Trilinos
    DEPENDS suitesparse
    INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/install
    GIT_REPOSITORY https://github.com/Trilinos/Trilinos
    GIT_TAG trilinos-release-12-12-1
    GIT_SHALLOW True
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Patch_EpetraExt_Transform_Composite.h <SOURCE_DIR>/packages/epetraext/src/transform/EpetraExt_Transform_Composite.h
    CMAKE_ARGS ${Xyce_TRILINOS_ARGS}
  )

  ExternalProject_Add (Xyce
    DEPENDS ${DEPENDENCIES}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}
    CMAKE_ARGS -DXyce_USE_SUPERBUILD=OFF
       -DCMAKE_PREFIX_PATH=${CMAKE_CURRENT_BINARY_DIR}/install
       -DFLEX_INCLUDE_DIR=/usr/include/
    INSTALL_COMMAND ""
    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
else()
  # Xyce should use the same compilers as Trilinos. Therefore, Trilinos must be
  # loaded before "project" is called.
  message(STATUS "Looking for required Trilinos packages:/n"
     "        Amesos Epetra EpetraExt Ifpack NOX Teuchos Sacado/n"
     "        Triutils AztecOO Belos TrilinosCouplings/n"
     "   Also looking for the optional packages:/n"
     "        Isorropia Zoltan ShyLU Basker Amesos2 Stokhos ROL")
  find_package(Trilinos 12.12
     REQUIRED Amesos Epetra EpetraExt Ifpack NOX Teuchos Sacado Triutils
          AztecOO Belos TrilinosCouplings
     OPTIONAL_COMPONENTS Isorropia Zoltan ShyLU Basker Amesos2 Stokhos ROL)
  message(STATUS "Looking for required Trilinos packages - found")

  # Set the compilers, so "project" finds the right ones
  # if the trilinos ones don't exist fall back on
  # environment defaults
  if( DEFINED CMAKE_CXX_COMPILER )
    message( "Using user defined CXX ${CMAKE_CXX_COMPILER}" )
  else( DEFINED CMAKE_CXX_COMPILER )
    message( "Using Trilinos CXX compiler" )
    set( CMAKE_CXX_COMPILER ${Trilinos_CXX_COMPILER} )
  endif( DEFINED CMAKE_CXX_COMPILER )

  if( DEFINED CMAKE_C_COMPILER )
    message( "Using user defined CC ${CMAKE_C_COMPILER}" )
  else( DEFINED CMAKE_C_COMPILER )
    message( "Using Trilinos C compiler" )
    set( CMAKE_C_COMPILER ${Trilinos_C_COMPILER} )
  endif( DEFINED CMAKE_C_COMPILER )

  project(Xyce VERSION 8.0.0 LANGUAGES CXX C)

  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  include(cmake/config.cmake)

  add_subdirectory(src)

  # add in unit tests subdirectory if it exists
  if ( EXISTS ${Xyce_SOURCE_DIR}/Xyce_UnitTests)
    add_subdirectory (Xyce_UnitTests)
  endif ( EXISTS ${Xyce_SOURCE_DIR}/Xyce_UnitTests)

  include(CPack)
  #See the CPackConfig.cmake in Xyce/cmake for settings
endif()
