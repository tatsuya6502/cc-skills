# cc-skills

Claude Code plugins and skills by [Tatsuya Kawano](https://github.com/tatsuya6502).

## Install

Add this repository as a plugin marketplace, then install the plugins you want:

```
/plugin marketplace add tatsuya6502/cc-skills
/plugin install memory-gc@cc-skills
```

## Plugins

| Plugin | Skills | Description |
|---|---|---|
| [memory-gc](plugins/memory-gc/) | `memory-gc`, `promote-knowledge` | Weekly, human-adjudicated maintenance for Claude Code's file-based project memory: a gc/triage pass, promotion of team-sharable knowledge into repo docs, and a SessionStart lint hook |

## License

[MIT](LICENSE)
