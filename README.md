Just some helper scripts

Simplified commit vs prototype view:
```
git clone https://git.kernel.og/pub/scm/linux/kernel/git/torbalds/linux.git
cd linux
../goTagFinder.sh kernel/porintk/printk.c early_printk >../mytaglist
../goMeldFromTagsList.sh ../mytaglist
```

Thats it for now
