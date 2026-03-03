mkdir /k8s
cbsd bhyve-p9shares mode=attach p9device=k8s p9path=/k8s jname=k8s

#+ worker
cbsd bhyve-p9shares mode=attach p9device=k8s p9path=/k8s jname=kworker1
cbsd bhyve-p9shares mode=attach p9device=k8s p9path=/k8s jname=kworker2
cbsd bhyve-p9shares mode=attach p9device=k8s p9path=/k8s jname=kworker3

# in guest
mkdir /k8s
mount -t 9p -o trans=virtio k8s /k8s


## ВСЕ ХОСТЫ ДОЛЖНЫ ИМЕТЬ /etc/hosts
172.16.0.51 worker-1
172.16.0.52 worker-2
172.16.0.53 worker-3
