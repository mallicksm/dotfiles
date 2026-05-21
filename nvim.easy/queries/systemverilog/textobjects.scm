;; extends

(module_declaration) @module.outer
(module_declaration) @module.inner

(class_declaration) @class.outer
(class_declaration) @class.inner

(ansi_port_declaration) @parameter.outer
(ansi_port_declaration) @parameter.inner
(tf_port_item) @parameter.outer
(tf_port_item) @parameter.inner
(actual_argument) @parameter.outer
(actual_argument) @parameter.inner
(class_constructor_arg) @parameter.outer
(class_constructor_arg) @parameter.inner

(module_declaration) @block.outer
(class_declaration) @block.outer

(module_instantiation) @instance.outer
(module_instantiation) @instance.inner
(hierarchical_instance) @instance.outer
(hierarchical_instance) @instance.inner
(named_port_connection) @field.outer
(named_port_connection) @field.inner
