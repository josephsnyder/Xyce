
# -- process files for this library ------------------------------------------

# class source list
set ( LoaderServices_SOURCES  
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_CktLoader.C 
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_HBLoader.C 
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_Loader.C 
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_NonlinearEquationLoader.C
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_ESLoader.C
      ${CMAKE_CURRENT_SOURCE_DIR}/N_LOA_PCELoader.C
      CACHE INTERNAL "X_S" )

set ( XYCE_SOURCES ${XYCE_SOURCES} ${LoaderServices_SOURCES} PARENT_SCOPE )
# add header files to project
set ( XYCE_INCLUDE_DIRECTORIES ${XYCE_INCLUDE_DIRECTORIES} 
      ${CMAKE_CURRENT_SOURCE_DIR}
      PARENT_SCOPE )




# -- build requested libraries -----------------------------------------------
set ( XYCE_PACKAGE_LIBRARIES ${XYCE_PACKAGE_LIBRARIES} 
      LoaderServices
      CACHE INTERNAL "X_L" )

