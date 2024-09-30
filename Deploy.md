Steps:

1. Create a new wallet `npm run generate-wallet`
2. In processes.yaml, set `file` as `build/send_custody_src.lua` and `npm run deploy`
3. Find the resulting `EvalOnce` message and copy it as `CUSTODY_SRC_MSG` in `src/custody-creator/const.tl`
4. In processes.yaml, set `file` as `build/custody-creator.lua` and `npm run deploy`
