project(objclint)

add_subdirectory(src)

install(TARGETS objclint-tool DESTINATION bin)
install(FILES ${PROJECT_SOURCE_DIR}/src/objclint DESTINATION bin)
