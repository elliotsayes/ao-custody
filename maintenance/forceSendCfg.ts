import * as path from 'node:path';
import * as fs from 'node:fs';
import * as process from 'node:process';
import { createDataItemSigner, message } from "@permaweb/aoconnect"

const CUSTODY_CREATOR = "zYBcGWB4KJeB4pc04XiNOKrD0DQBPelvNBbfDnqiunQ"

async function main() {
  const targetProcess = process.argv[2];
  const targetBeneficiary = process.argv[3];

  if (!targetProcess) {
    console.error('Usage: node forceSendCfg.js <targetProcess> <targetBeneficiary>');
    process.exit(1);
  }

  if (!targetProcess.match(/^[a-zA-Z0-9_-]{43}$/)) {
    console.error('Invalid target process: ' + targetProcess);
    process.exit(1);
  }

  if (!targetBeneficiary) {
    console.error('Usage: node forceSendCfg.js <targetProcess> <targetBeneficiary>');
    process.exit(1);
  }

  if (!targetBeneficiary.match(/^[a-zA-Z0-9_-]{43}$/)) {
    console.error('Invalid target beneficiary: ' + targetBeneficiary);
    process.exit(1);
  }
  
  const walletPath = path.join('.', '.secret', 'wallet.json');
  const wallet = JSON.parse(fs.readFileSync(walletPath, 'utf-8'));
  const signer = createDataItemSigner(wallet);

  const sendCfgSrc = `
CREATOR_PROCESS = "zYBcGWB4KJeB4pc04XiNOKrD0DQBPelvNBbfDnqiunQ"
BENEFICIARY_ADDRESS = "${targetBeneficiary}"

ao.addAssignable("CUSTODY_SRC_MSG", {
  Id = "JeAC3zMdipFZD0XWg_w4g9I0EshiJwCUXDNBk2FvGZY"
})

local eval = require('.eval')(ao)
EvalOnceHistory = EvalOnceHistory or {}
Handlers.add(
  'EvalOnce',
  Handlers.utils.hasMatchingTag('Action', 'EvalOnce'),
  function(msg)
    if msg.From == Owner and not EvalOnceHistory[msg.Id] then
      EvalOnceHistory[msg.Id] = true
      eval(msg)
    end
  end
)

ao.send({
  Target = CREATOR_PROCESS,
  Action = "AckCfg"
})
`

  const sendCfgEvalCommand = `
Send({
  Target = "${targetProcess}",
  Action = "Eval",
  Data = [[${sendCfgSrc}]]
})
`;

  const sendCfgMsgEvalCommandMsgId = await message({
    process: CUSTODY_CREATOR,
    tags: [{
      name: 'Action',
      value: 'Eval',
    }],
    data: sendCfgEvalCommand,
    signer,
  })

  console.log(`sendCfgMsgEvalCommandMsgId: ${sendCfgMsgEvalCommandMsgId}`);
}

main().catch(console.error);
