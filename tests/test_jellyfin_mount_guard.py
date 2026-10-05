import unittest
import subprocess
from pathlib import Path
from unittest import mock

scope={'__name__':'guard_test'}
source=Path(__file__).resolve().parents[1]/'bin'/'fumetaos-jellyfin-mount-guard'
exec(compile(source.read_text(),str(source),'exec'),scope)

class GuardTests(unittest.TestCase):
    def setUp(self):
        self.before={'State':{'Running':True},'Mounts':[
            {'Destination':'/Media','Source':'/mnt/datos/Multimedia','Type':'bind'},
            {'Destination':'/TimeCapsule','Source':'/DATA/TimeCapsule','Type':'bind'}]}
    def ready(self,args,timeout=15):
        import json
        if args[0]=='findmnt':
            root=args[args.index('-T')+1]
            return subprocess.CompletedProcess(args,0,stdout=json.dumps({'filesystems':[{
                'target':root,'source':'//192.168.1.2/Data',
                'fstype':'ext4' if root=='/mnt/datos' else 'cifs'}]}))
        return subprocess.CompletedProcess(args,0,stdout='')
    def test_ready_mounts(self):
        with mock.patch.dict(scope,inspect=lambda:self.before,call=self.ready):
            self.assertIs(scope['check_paths'](),self.before)
    def test_missing_mount_waits_without_restart(self):
        failed=lambda args,timeout=15:subprocess.CompletedProcess(args,1,stdout='')
        with mock.patch.dict(scope,inspect=lambda:self.before,call=failed):
            with self.assertRaises(scope['Waiting']):
                scope['check_paths']()
    def test_unexpected_bind_refused(self):
        self.before['Mounts'][0]['Source']='/unexpected'
        with mock.patch.dict(scope,inspect=lambda:self.before,call=self.ready):
            with self.assertRaises(RuntimeError):
                scope['check_paths']()
    def test_stopped_container_is_respected(self):
        import fcntl
        self.before['State']['Running']=False
        commands=[]
        def q(args,timeout=15):
            commands.append(args)
            return 'jellyfin\n'
        with mock.patch.dict(scope,inspect=lambda:self.before,call=self.ready,query=q), \
             mock.patch.object(scope['os'],'geteuid',return_value=0), \
             mock.patch.object(scope['os'],'open',return_value=123), \
             mock.patch.object(scope['sys'],'argv',['guard','--check-only']), \
             mock.patch.object(fcntl,'flock'):
            self.assertEqual(scope['main'](),0)
        self.assertFalse(any('restart' in args for args in commands))
    def test_check_only_cannot_restart(self):
        import fcntl
        commands=[]
        def q(args,timeout=15):
            commands.append(args)
            return 'jellyfin\n'
        with mock.patch.dict(scope,inspect=lambda:self.before,check_paths=lambda:self.before,
                             identity=lambda path,container=False:'old' if container else 'new',
                             call=self.ready,query=q), \
             mock.patch.object(scope['os'],'geteuid',return_value=0), \
             mock.patch.object(scope['os'],'open',return_value=123), \
             mock.patch.object(scope['sys'],'argv',['guard','--check-only']), \
             mock.patch.object(fcntl,'flock'):
            with self.assertRaises(RuntimeError):
                scope['main']()
        self.assertFalse(any('restart' in args for args in commands))

if __name__=='__main__':
    unittest.main()
