#!/bin/sh
kubectl run busybox --image=busybox:1.28 --rm -it --restart=Never --kubeconfig=/k8s/pki/admin.kubeconfig -- sh

nslookup kubernetes.default


Будет подвисать:

Это классическое поведение
nslookup в Kubernetes, когда транспортный уровень (UDP/TCP) работает, но есть нюанс в настройке IPv6 или Forwarding.
Подвисание после вывода Address 1: 10.32.0.10 обычно означает, что запрос на A-запись (IPv4) прошел успешно, но клиент (BusyBox) отправил второй запрос на AAAA-запись (IPv6), на который не получил ответа или получил его с большой задержкой.
Почему это происходит в вашем "Hard Way":

    IPv6 в CoreDNS: По умолчанию CoreDNS может пытаться резолвить IPv6, но если в вашем Debian-окружении IPv6 не настроен или фильтруется iptables, запрос будет висеть до таймаута.
    Missing ndots: В Kubernetes конфиг /etc/resolv.conf внутри пода содержит параметр ndots:5. Это заставляет nslookup пробовать разные суффиксы (например, kubernetes.default.svc.cluster.local), что генерирует пачку запросов.
    Forwarding (Внешний мир): CoreDNS пытается переслать запросы, которые он не знает, на /etc/resolv.conf хоста. Если на Debian-ноде настроен какой-то специфичный резолвер (например, systemd-resolved), может возникнуть петля или блокировка.

Как проверить, в чем именно дело:
1. Проверьте логи CoreDNS на мастере:
bash

kubectl logs -n kube-system -l k8s-app=kube-dns --kubeconfig=/k8s/pki/admin.kubeconfig

Use code with caution.
Если там пусто или ошибки i/o timeout, значит CoreDNS не может достучаться до внешних DNS или падает при обработке IPv6.
2. Попробуйте принудительно IPv4 в BusyBox:
bash

# Внутри пода busybox
nslookup -type=A kubernetes.default 10.32.0.10

Use code with caution.
Если эта команда отработает мгновенно — проблема в обработке IPv6 запросов.
3. Проверьте IP-Forwarding на воркерах:
Мы это делали, но убедитесь еще раз, что iptables не блокирует трафик между интерфейсом cni0 и основной сетью:
bash

sudo iptables -P FORWARD ACCEPT

Use code with caution.
Финальный штрих:
Попробуйте сделать curl (если есть) или просто ping до имени:
bash

ping kubernetes.default

Use code with caution.
Если пинг идет (даже если nslookup тупит), значит инфраструктура DNS исправна, а "тормоза" — это просто особенности поведения старых версий nslookup в BusyBox при работе с ndots.
Удалось получить мгновенный ответ с -type=A? Если да, то ваш "Hard Way" кластер полностью готов к деплою реальных приложений.
Чем планируете заняться теперь: нагрузочным тестированием этого ручного монстра или перейдете к изучению Ingress-контроллеров?

