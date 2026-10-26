-- Editor-only overrides for ty. Rules go in [tool.ty] of the project.
return {
  settings = {
    ty = {
      -- Check the whole project, not only open files.
      diagnosticMode = 'workspace',
    },
  },
}
