// Native Node modules only. PowerShell is the public entry point on Windows.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {validateProject,validateSourceManifest,validateEvidence,GAME_IDS} from './release-guards.mjs';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
process.chdir(root);
const read=p=>fs.readFileSync(p,'utf8');
const json=p=>JSON.parse(read(p));
const write=(p,s)=>{fs.mkdirSync(path.dirname(p),{recursive:true});fs.writeFileSync(p,s);};
const digest=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const tool=(name,exe=name)=>path.join(root,'.tools',name,exe+'.exe');
const run=(file,args)=>execFileSync(file,args,{cwd:root,encoding:'utf8',stdio:['ignore','pipe','pipe'],maxBuffer:16*1024*1024});
const git=(...args)=>run('git',args).trim();
const files=dir=>fs.readdirSync(dir,{withFileTypes:true}).flatMap(e=>e.isDirectory()?files(path.join(dir,e.name)):[path.join(dir,e.name)]);
const inputs=['src','vendor','scripts','tests','.darklua.json','.luaurc','stylua.toml','dependencies.lock.json'];
const entries={loader:'src/bootstrap/Main.luau',AnimeVanguards:'src/games/AnimeVanguards/Entry.luau',AnimeExpeditions:'src/games/AnimeExpeditions/Entry.luau'};
const paths={loader:'loader.lua',ui:'ui.lua',AnimeVanguards:'games/AnimeVanguards.lua',AnimeExpeditions:'games/AnimeExpeditions.lua'};
function projectCheck(manifest=json('manifest.json')){
    const metadata=Object.fromEntries(GAME_IDS.map(id=>[id,read('src/games/'+id+'/Metadata.luau')]));
    validateProject(manifest,json('status.json'),read('src/games/Registry.luau'),metadata);
}
function vendorCheck(){
    const lock=json('dependencies.lock.json');
    if(digest('vendor/WindUI/source.lua')!==lock.windui.vendoredSha256)throw Error('WindUI checksum mismatch');
    if(digest('vendor/WindUI/LICENSE')!==lock.windui.licenseSha256)throw Error('WindUI license checksum mismatch');
    for(const [name,spec] of Object.entries(lock.tools)){
        if(spec.executables)for(const [exe,hash]of Object.entries(spec.executables))if(digest(tool(name,exe))!==hash)throw Error('Tool binary checksum mismatch: '+exe);
    }
}
function buildInto(directory){
    vendorCheck();
    for(const [key,input]of Object.entries(entries)){
        const output=path.join(directory,paths[key]);fs.mkdirSync(path.dirname(output),{recursive:true});
        run(tool('darklua'),['process','-c','.darklua.json',input,output]);
    }
    write(path.join(directory,paths.ui),read('vendor/WindUI/source.lua'));
    const artifacts={};
    for(const [key,relative]of Object.entries(paths)){
        const p=path.join(directory,relative);
        run(tool('luau','luau-compile'),['--null',p]);
        artifacts[key]={path:'dist/'+relative,sha256:digest(p),bytes:fs.statSync(p).size};
    }
    return artifacts;
}
function build(){
    const manifest=json('manifest.json');
    projectCheck(manifest);
    const release=process.argv.includes('--release');
    let sourceCommit=null;
    if(release){
        sourceCommit=git('rev-parse','HEAD');
        if(git('status','--porcelain'))throw Error('Release build requires a clean committed source checkout');
        const repository=process.argv[process.argv.indexOf('--repository')+1];
        if(!repository?.match(/^[\w-]+\/[\w.-]+$/))throw Error('An actual owner/repository is required');
        // Actual runtime evidence is a gate, not an inferred result of unit tests.
        const evidence=json('work/runtime-verification.json');
        validateEvidence(evidence,sourceCommit,manifest);
        manifest.repository=repository;
    }
    manifest.sourceCommit=sourceCommit;manifest.mode=release?'release':'development';
    manifest.artifactRevision=null;
    manifest.artifacts=buildInto('dist');
    write('manifest.json',JSON.stringify(manifest,null,2)+'\n');
    write('manifest.txt',[
        'ViperHub NextGen '+manifest.version,'Mode: '+manifest.mode,
        'sourceCommit: '+(sourceCommit??'unavailable; uncommitted development build'),
        ...Object.entries(manifest.artifacts).map(([id,a])=>id+' '+a.sha256+' '+a.bytes+' bytes'),'',
    ].join('\n'));
    console.log('Built '+Object.keys(manifest.artifacts).length+' artifacts ('+manifest.mode+')');
}
function verify(development=false){
    vendorCheck();const m=json('manifest.json');projectCheck(m);
    for(const [id,a]of Object.entries(m.artifacts)){
        if(a.path!=='dist/'+paths[id])throw Error('Unexpected artifact path');
        if(digest(a.path)!==a.sha256||fs.statSync(a.path).size!==a.bytes)throw Error('Artifact mismatch: '+id);
    }
    if(Object.keys(m.artifacts).length!==4)throw Error('Missing artifacts');
    if(!development){
        if(m.mode!=='release'||!m.sourceCommit?.match(/^[a-f0-9]{40}$/)||!m.artifactRevision?.match(/^[a-f0-9]{40}$/))throw Error('Not a published release manifest');
        git('cat-file','-e',m.sourceCommit+'^{commit}');
        if(git('diff',m.sourceCommit,'--',...inputs))throw Error('Build inputs differ from sourceCommit');
        if(git('ls-files','--others','--exclude-standard','--',...inputs))throw Error('Untracked build inputs');
        validateSourceManifest(m,JSON.parse(git('show',m.sourceCommit+':manifest.json')));
        for(const a of Object.values(m.artifacts)){
            const bytes=execFileSync('git',['show',m.artifactRevision+':'+a.path],{cwd:root,maxBuffer:16*1024*1024});
            if(crypto.createHash('sha256').update(bytes).digest('hex')!==a.sha256)throw Error('Published revision mismatch');
        }
    }
    const replay=buildInto('work/replay');
    if(JSON.stringify(replay)!==JSON.stringify(m.artifacts))throw Error('Rebuilt output differs from manifest');
    console.log('Artifact hashes, sizes and deterministic rebuild verified');
}
function long(s){let eq='=';while(s.includes(']'+eq+']'))eq+='=';return '['+eq+'['+s+']'+eq+']';}
function harness(){
    const m=json('manifest.json');
    const values=Object.entries(m.artifacts).filter(([k])=>k!=='loader').map(([k,a])=>'['+JSON.stringify(k)+'] = '+long(read(a.path))).join(',\n');
    const metadata='{mode="development", games={'+Object.entries(m.games).map(([id,g])=>id+'={version='+JSON.stringify(g.version)+'}').join(',')+'}}';
    const source='-- GENERATED local-only smoke harness; no publication required.\nlocal env=getfenv()\nlocal previous=env.VIPER_DEV_ARTIFACTS\nenv.VIPER_DEV_ARTIFACTS={manifest='+metadata+',\n'+values+'}\nlocal ok,result=pcall(function() return assert(loadstring('+long(read('dist/loader.lua'))+'))() end)\nenv.VIPER_DEV_ARTIFACTS=previous\nif not ok then error("VIPER_SMOKE_FAILED") end\nreturn result\n';
    write('work/runtime-smoke.lua',source);
    console.log('Local runtime harness: work/runtime-smoke.lua');
}
function check(){
    vendorCheck();
    projectCheck();
    console.log(run('node',['tests/release-guards.test.mjs']));
    console.log(run(tool('stylua'),['--check','src','tests']));
    console.log(run(tool('luau','luau-analyze'),['src','tests']));
    for(const p of files('src').filter(p=>p.endsWith('.luau'))){
        const s=read(p);if(!s.startsWith('--!strict')||!s.includes('Purpose:')||!s.includes('Dependencies:'))throw Error('Missing module contract: '+p);
        if(/\bsyn\s*\.|(?<![\w.])(?:wait|spawn|delay)\s*\(/.test(s))throw Error('Forbidden API: '+p);
    }
    console.log(run(tool('luau'),['tests/unit/run.luau']));
    if(json('manifest.json').mode==='release') buildInto('dist'); else build();
    const integration='local run=require("../tests/integration/Bootstrap")\nrun('+long(read('dist/loader.lua'))+')\n';
    write('work/integration.luau',integration);
    console.log(run(tool('luau'),['work/integration.luau']));
    verify(true);harness();
    console.log('Local gates passed; live runtime verification is separate.');
}
try{
    switch(process.argv[2]){
        case 'build':build();harness();break;
        case 'check':check();break;
        case 'verify':verify(process.argv.includes('--development'));break;
        default:throw Error('Expected build, check or verify');
    }
}catch(error){console.error(error.stderr?.toString()||error.stack);process.exitCode=1;}
