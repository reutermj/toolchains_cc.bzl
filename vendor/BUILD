package(default_visibility = ["//visibility:public"])

constraint_setting(
    name = "vendor",
    default_constraint_value = "ubuntu",
)

constraint_value(
    name = "ubuntu",
    constraint_setting = ":vendor",
)

constraint_value(
    name = "alpine",
    constraint_setting = ":vendor",
)
