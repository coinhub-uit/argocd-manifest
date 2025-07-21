set dotenv-required

mod cluster "./cluster/justfile"
mod vault "./cluster/vault/justfile"

default:
  @just --list
