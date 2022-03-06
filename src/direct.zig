const internal = @import("./internal.zig");
const string = []const u8;

pub const Port = struct {
    IP: string,
    PrivatePort: i32,
    PublicPort: i32,
    Type: enum {
        tcp,
        udp,
        sctp,
    },
};

pub const MountPoint = struct {
    Type: string,
    Name: string,
    Source: string,
    Destination: string,
    Driver: string,
    Mode: string,
    RW: bool,
    Propagation: string,
};

pub const DeviceMapping = struct {
    PathOnHost: string,
    PathInContainer: string,
    CgroupPermissions: string,
};

pub const DeviceRequest = struct {
    Driver: string,
    Count: i32,
    DeviceIDs: []const string,
    Capabilities: []const []const string,
    Options: struct {},
};

pub const ThrottleDevice = struct {
    Path: string,
    Rate: i32,
};

pub const Mount = struct {
    Target: string,
    Source: string,
    Type: enum {
        bind,
        volume,
        tmpfs,
        npipe,
    },
    ReadOnly: bool,
    Consistency: string,
    BindOptions: struct {
        Propagation: enum {
            private,
            rprivate,
            shared,
            rshared,
            slave,
            rslave,
        },
        NonRecursive: bool,
    },
    VolumeOptions: struct {
        NoCopy: bool,
        Labels: struct {},
        DriverConfig: struct {
            Name: string,
            Options: struct {},
        },
    },
    TmpfsOptions: struct {
        SizeBytes: i32,
        Mode: i32,
    },
};

pub const RestartPolicy = struct {
    Name: enum {
        no,
        always,
        @"unless-stopped",
        @"on-failure",
    },
    MaximumRetryCount: i32,
};

pub const Resources = struct {
    CpuShares: i32,
    Memory: i32,
    CgroupParent: string,
    BlkioWeight: i32,
    BlkioWeightDevice: []const struct {
        Path: string,
        Weight: i32,
    },
    BlkioDeviceReadBps: []const ThrottleDevice,
    BlkioDeviceWriteBps: []const ThrottleDevice,
    BlkioDeviceReadIOps: []const ThrottleDevice,
    BlkioDeviceWriteIOps: []const ThrottleDevice,
    CpuPeriod: i32,
    CpuQuota: i32,
    CpuRealtimePeriod: i32,
    CpuRealtimeRuntime: i32,
    CpusetCpus: string,
    CpusetMems: string,
    Devices: []const DeviceMapping,
    DeviceCgroupRules: []const string,
    DeviceRequests: []const DeviceRequest,
    KernelMemory: i32,
    KernelMemoryTCP: i32,
    MemoryReservation: i32,
    MemorySwap: i32,
    MemorySwappiness: i32,
    NanoCpus: i32,
    OomKillDisable: bool,
    Init: bool,
    PidsLimit: i32,
    Ulimits: []const struct {
        Name: string,
        Soft: i32,
        Hard: i32,
    },
    CpuCount: i32,
    CpuPercent: i32,
    IOMaximumIOps: i32,
    IOMaximumBandwidth: i32,
};

pub const Limit = struct {
    NanoCPUs: i32,
    MemoryBytes: i32,
    Pids: i32,
};

pub const ResourceObject = struct {
    NanoCPUs: i32,
    MemoryBytes: i32,
    GenericResources: GenericResources,
};

pub const GenericResources = []const struct {
    NamedResourceSpec: struct {
        Kind: string,
        Value: string,
    },
    DiscreteResourceSpec: struct {
        Kind: string,
        Value: i32,
    },
};

pub const HealthConfig = struct {
    Test: []const string,
    Interval: i32,
    Timeout: i32,
    Retries: i32,
    StartPeriod: i32,
};

pub const Health = struct {
    Status: enum {
        none,
        starting,
        healthy,
        unhealthy,
    },
    FailingStreak: i32,
    Log: []const HealthcheckResult,
};

pub const HealthcheckResult = struct {
    Start: string,
    End: string,
    ExitCode: i32,
    Output: string,
};

pub const HostConfig = internal.AllOf(&.{
    Resources,
    struct {
        Binds: []const string,
        ContainerIDFile: string,
        LogConfig: struct {
            Type: enum {
                @"json-file",
                syslog,
                journald,
                gelf,
                fluentd,
                awslogs,
                splunk,
                etwlogs,
                none,
            },
            Config: struct {},
        },
        NetworkMode: string,
        PortBindings: PortMap,
        RestartPolicy: RestartPolicy,
        AutoRemove: bool,
        VolumeDriver: string,
        VolumesFrom: []const string,
        Mounts: []const Mount,
        CapAdd: []const string,
        CapDrop: []const string,
        CgroupnsMode: enum {
            private,
            host,
        },
        Dns: []const string,
        DnsOptions: []const string,
        DnsSearch: []const string,
        ExtraHosts: []const string,
        GroupAdd: []const string,
        IpcMode: string,
        Cgroup: string,
        Links: []const string,
        OomScoreAdj: i32,
        PidMode: string,
        Privileged: bool,
        PublishAllPorts: bool,
        ReadonlyRootfs: bool,
        SecurityOpt: []const string,
        StorageOpt: struct {},
        Tmpfs: struct {},
        UTSMode: string,
        UsernsMode: string,
        ShmSize: i32,
        Sysctls: struct {},
        Runtime: string,
        ConsoleSize: []const i32,
        Isolation: enum {
            default,
            process,
            hyperv,
        },
        MaskedPaths: []const string,
        ReadonlyPaths: []const string,
    },
});

pub const ContainerConfig = struct {
    Hostname: string,
    Domainname: string,
    User: string,
    AttachStdin: bool,
    AttachStdout: bool,
    AttachStderr: bool,
    ExposedPorts: struct {},
    Tty: bool,
    OpenStdin: bool,
    StdinOnce: bool,
    Env: []const string,
    Cmd: []const string,
    Healthcheck: HealthConfig,
    ArgsEscaped: bool,
    Image: string,
    Volumes: struct {},
    WorkingDir: string,
    Entrypoint: []const string,
    NetworkDisabled: bool,
    MacAddress: string,
    OnBuild: []const string,
    Labels: struct {},
    StopSignal: string,
    StopTimeout: i32,
    Shell: []const string,
};

pub const NetworkingConfig = struct {
    EndpointsConfig: struct {},
};

pub const NetworkSettings = struct {
    Bridge: string,
    SandboxID: string,
    HairpinMode: bool,
    LinkLocalIPv6Address: string,
    LinkLocalIPv6PrefixLen: i32,
    Ports: PortMap,
    SandboxKey: string,
    SecondaryIPAddresses: []const Address,
    SecondaryIPv6Addresses: []const Address,
    EndpointID: string,
    Gateway: string,
    GlobalIPv6Address: string,
    GlobalIPv6PrefixLen: i32,
    IPAddress: string,
    IPPrefixLen: i32,
    IPv6Gateway: string,
    MacAddress: string,
    Networks: struct {},
};

pub const Address = struct {
    Addr: string,
    PrefixLen: i32,
};

pub const PortMap = struct {};

pub const PortBinding = struct {
    HostIp: string,
    HostPort: string,
};

pub const GraphDriverData = struct {
    Name: string,
    Data: struct {},
};

pub const Image = struct {
    Id: string,
    RepoTags: []const string,
    RepoDigests: []const string,
    Parent: string,
    Comment: string,
    Created: string,
    Container: string,
    ContainerConfig: ContainerConfig,
    DockerVersion: string,
    Author: string,
    Config: ContainerConfig,
    Architecture: string,
    Os: string,
    OsVersion: string,
    Size: i32,
    VirtualSize: i32,
    GraphDriver: GraphDriverData,
    RootFS: struct {
        Type: string,
        Layers: []const string,
        BaseLayer: string,
    },
    Metadata: struct {
        LastTagTime: string,
    },
};

pub const ImageSummary = struct {
    Id: string,
    ParentId: string,
    RepoTags: []const string,
    RepoDigests: []const string,
    Created: i32,
    Size: i32,
    SharedSize: i32,
    VirtualSize: i32,
    Labels: struct {},
    Containers: i32,
};

pub const AuthConfig = struct {
    username: string,
    password: string,
    email: string,
    serveraddress: string,
};

pub const ProcessConfig = struct {
    privileged: bool,
    user: string,
    tty: bool,
    entrypoint: string,
    arguments: []const string,
};

pub const Volume = struct {
    Name: string,
    Driver: string,
    Mountpoint: string,
    CreatedAt: string,
    Status: struct {},
    Labels: struct {},
    Scope: enum {
        local,
        global,
    },
    Options: struct {},
    UsageData: struct {
        Size: i32,
        RefCount: i32,
    },
};

pub const Network = struct {
    Name: string,
    Id: string,
    Created: string,
    Scope: string,
    Driver: string,
    EnableIPv6: bool,
    IPAM: IPAM,
    Internal: bool,
    Attachable: bool,
    Ingress: bool,
    Containers: struct {},
    Options: struct {},
    Labels: struct {},
};

pub const IPAM = struct {
    Driver: string,
    Config: []const struct {},
    Options: struct {},
};

pub const NetworkContainer = struct {
    Name: string,
    EndpointID: string,
    MacAddress: string,
    IPv4Address: string,
    IPv6Address: string,
};

pub const BuildInfo = struct {
    id: string,
    stream: string,
    @"error": string,
    errorDetail: ErrorDetail,
    status: string,
    progress: string,
    progressDetail: ProgressDetail,
    aux: ImageID,
};

pub const BuildCache = struct {
    ID: string,
    Parent: string,
    Type: string,
    Description: string,
    InUse: bool,
    Shared: bool,
    Size: i32,
    CreatedAt: string,
    LastUsedAt: string,
    UsageCount: i32,
};

pub const ImageID = struct {
    ID: string,
};

pub const CreateImageInfo = struct {
    id: string,
    @"error": string,
    status: string,
    progress: string,
    progressDetail: ProgressDetail,
};

pub const PushImageInfo = struct {
    @"error": string,
    status: string,
    progress: string,
    progressDetail: ProgressDetail,
};

pub const ErrorDetail = struct {
    code: i32,
    message: string,
};

pub const ProgressDetail = struct {
    current: i32,
    total: i32,
};

pub const ErrorResponse = struct {
    message: string,
};

pub const IdResponse = struct {
    Id: string,
};

pub const EndpointSettings = struct {
    IPAMConfig: EndpointIPAMConfig,
    Links: []const string,
    Aliases: []const string,
    NetworkID: string,
    EndpointID: string,
    Gateway: string,
    IPAddress: string,
    IPPrefixLen: i32,
    IPv6Gateway: string,
    GlobalIPv6Address: string,
    GlobalIPv6PrefixLen: i32,
    MacAddress: string,
    DriverOpts: struct {},
};

pub const EndpointIPAMConfig = struct {
    IPv4Address: string,
    IPv6Address: string,
    LinkLocalIPs: []const string,
};

pub const PluginMount = struct {
    Name: string,
    Description: string,
    Settable: []const string,
    Source: string,
    Destination: string,
    Type: string,
    Options: []const string,
};

pub const PluginDevice = struct {
    Name: string,
    Description: string,
    Settable: []const string,
    Path: string,
};

pub const PluginEnv = struct {
    Name: string,
    Description: string,
    Settable: []const string,
    Value: string,
};

pub const PluginInterfaceType = struct {
    Prefix: string,
    Capability: string,
    Version: string,
};

pub const PluginPrivilege = struct {
    Name: string,
    Description: string,
    Value: []const string,
};

pub const Plugin = struct {
    Id: string,
    Name: string,
    Enabled: bool,
    Settings: struct {
        Mounts: []const PluginMount,
        Env: []const string,
        Args: []const string,
        Devices: []const PluginDevice,
    },
    PluginReference: string,
    Config: struct {
        DockerVersion: string,
        Description: string,
        Documentation: string,
        Interface: struct {
            Types: []const PluginInterfaceType,
            Socket: string,
            ProtocolScheme: enum {
                @"moby.plugins.http/v1",
            },
        },
        Entrypoint: []const string,
        WorkDir: string,
        User: struct {
            UID: i32,
            GID: i32,
        },
        Network: struct {
            Type: string,
        },
        Linux: struct {
            Capabilities: []const string,
            AllowAllDevices: bool,
            Devices: []const PluginDevice,
        },
        PropagatedMount: string,
        IpcHost: bool,
        PidHost: bool,
        Mounts: []const PluginMount,
        Env: []const PluginEnv,
        Args: struct {
            Name: string,
            Description: string,
            Settable: []const string,
            Value: []const string,
        },
        rootfs: struct {
            type: string,
            diff_ids: []const string,
        },
    },
};

pub const ObjectVersion = struct {
    Index: i32,
};

pub const NodeSpec = struct {
    Name: string,
    Labels: struct {},
    Role: enum {
        worker,
        manager,
    },
    Availability: enum {
        active,
        pause,
        drain,
    },
};

pub const Node = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: NodeSpec,
    Description: NodeDescription,
    Status: NodeStatus,
    ManagerStatus: ManagerStatus,
};

pub const NodeDescription = struct {
    Hostname: string,
    Platform: Platform,
    Resources: ResourceObject,
    Engine: EngineDescription,
    TLSInfo: TLSInfo,
};

pub const Platform = struct {
    Architecture: string,
    OS: string,
};

pub const EngineDescription = struct {
    EngineVersion: string,
    Labels: struct {},
    Plugins: []const struct {
        Type: string,
        Name: string,
    },
};

pub const TLSInfo = struct {
    TrustRoot: string,
    CertIssuerSubject: string,
    CertIssuerPublicKey: string,
};

pub const NodeStatus = struct {
    State: NodeState,
    Message: string,
    Addr: string,
};

pub const NodeState = enum {
    unknown,
    down,
    ready,
    disconnected,
};

pub const ManagerStatus = struct {
    Leader: bool,
    Reachability: Reachability,
    Addr: string,
};

pub const Reachability = enum {
    unknown,
    @"unreachable",
    reachable,
};

pub const SwarmSpec = struct {
    Name: string,
    Labels: struct {},
    Orchestration: struct {
        TaskHistoryRetentionLimit: i32,
    },
    Raft: struct {
        SnapshotInterval: i32,
        KeepOldSnapshots: i32,
        LogEntriesForSlowFollowers: i32,
        ElectionTick: i32,
        HeartbeatTick: i32,
    },
    Dispatcher: struct {
        HeartbeatPeriod: i32,
    },
    CAConfig: struct {
        NodeCertExpiry: i32,
        ExternalCAs: []const struct {
            Protocol: enum {
                cfssl,
            },
            URL: string,
            Options: struct {},
            CACert: string,
        },
        SigningCACert: string,
        SigningCAKey: string,
        ForceRotate: i32,
    },
    EncryptionConfig: struct {
        AutoLockManagers: bool,
    },
    TaskDefaults: struct {
        LogDriver: struct {
            Name: string,
            Options: struct {},
        },
    },
};

pub const ClusterInfo = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: SwarmSpec,
    TLSInfo: TLSInfo,
    RootRotationInProgress: bool,
    DataPathPort: i32,
    DefaultAddrPool: []const string,
    SubnetSize: i32,
};

pub const JoinTokens = struct {
    Worker: string,
    Manager: string,
};

pub const Swarm = internal.AllOf(&.{
    ClusterInfo,
    struct {
        JoinTokens: JoinTokens,
    },
});

pub const TaskSpec = struct {
    PluginSpec: struct {
        Name: string,
        Remote: string,
        Disabled: bool,
        PluginPrivilege: []const PluginPrivilege,
    },
    ContainerSpec: struct {
        Image: string,
        Labels: struct {},
        Command: []const string,
        Args: []const string,
        Hostname: string,
        Env: []const string,
        Dir: string,
        User: string,
        Groups: []const string,
        Privileges: struct {
            CredentialSpec: struct {
                Config: string,
                File: string,
                Registry: string,
            },
            SELinuxContext: struct {
                Disable: bool,
                User: string,
                Role: string,
                Type: string,
                Level: string,
            },
        },
        TTY: bool,
        OpenStdin: bool,
        ReadOnly: bool,
        Mounts: []const Mount,
        StopSignal: string,
        StopGracePeriod: i32,
        HealthCheck: HealthConfig,
        Hosts: []const string,
        DNSConfig: struct {
            Nameservers: []const string,
            Search: []const string,
            Options: []const string,
        },
        Secrets: []const struct {
            File: struct {
                Name: string,
                UID: string,
                GID: string,
                Mode: i32,
            },
            SecretID: string,
            SecretName: string,
        },
        Configs: []const struct {
            File: struct {
                Name: string,
                UID: string,
                GID: string,
                Mode: i32,
            },
            Runtime: struct {},
            ConfigID: string,
            ConfigName: string,
        },
        Isolation: enum {
            default,
            process,
            hyperv,
        },
        Init: bool,
        Sysctls: struct {},
        CapabilityAdd: []const string,
        CapabilityDrop: []const string,
        Ulimits: []const struct {
            Name: string,
            Soft: i32,
            Hard: i32,
        },
    },
    NetworkAttachmentSpec: struct {
        ContainerID: string,
    },
    Resources: struct {
        Limits: Limit,
        Reservation: ResourceObject,
    },
    RestartPolicy: struct {
        Condition: enum {
            none,
            @"on-failure",
            any,
        },
        Delay: i32,
        MaxAttempts: i32,
        Window: i32,
    },
    Placement: struct {
        Constraints: []const string,
        Preferences: []const struct {
            Spread: struct {
                SpreadDescriptor: string,
            },
        },
        MaxReplicas: i32,
        Platforms: []const Platform,
    },
    ForceUpdate: i32,
    Runtime: string,
    Networks: []const NetworkAttachmentConfig,
    LogDriver: struct {
        Name: string,
        Options: struct {},
    },
};

pub const TaskState = enum {
    new,
    allocated,
    pending,
    assigned,
    accepted,
    preparing,
    ready,
    starting,
    running,
    complete,
    shutdown,
    failed,
    rejected,
    remove,
    orphaned,
};

pub const Task = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Name: string,
    Labels: struct {},
    Spec: TaskSpec,
    ServiceID: string,
    Slot: i32,
    NodeID: string,
    AssignedGenericResources: GenericResources,
    Status: struct {
        Timestamp: string,
        State: TaskState,
        Message: string,
        Err: string,
        ContainerStatus: struct {
            ContainerID: string,
            PID: i32,
            ExitCode: i32,
        },
    },
    DesiredState: TaskState,
    JobIteration: ObjectVersion,
};

pub const ServiceSpec = struct {
    Name: string,
    Labels: struct {},
    TaskTemplate: TaskSpec,
    Mode: struct {
        Replicated: struct {
            Replicas: i32,
        },
        Global: struct {},
        ReplicatedJob: struct {
            MaxConcurrent: i32,
            TotalCompletions: i32,
        },
        GlobalJob: struct {},
    },
    UpdateConfig: struct {
        Parallelism: i32,
        Delay: i32,
        FailureAction: enum {
            @"continue",
            pause,
            rollback,
        },
        Monitor: i32,
        MaxFailureRatio: f64,
        Order: enum {
            @"stop-first",
            @"start-first",
        },
    },
    RollbackConfig: struct {
        Parallelism: i32,
        Delay: i32,
        FailureAction: enum {
            @"continue",
            pause,
        },
        Monitor: i32,
        MaxFailureRatio: f64,
        Order: enum {
            @"stop-first",
            @"start-first",
        },
    },
    Networks: []const NetworkAttachmentConfig,
    EndpointSpec: EndpointSpec,
};

pub const EndpointPortConfig = struct {
    Name: string,
    Protocol: enum {
        tcp,
        udp,
        sctp,
    },
    TargetPort: i32,
    PublishedPort: i32,
    PublishMode: enum {
        ingress,
        host,
    },
};

pub const EndpointSpec = struct {
    Mode: enum {
        vip,
        dnsrr,
    },
    Ports: []const EndpointPortConfig,
};

pub const Service = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: ServiceSpec,
    Endpoint: struct {
        Spec: EndpointSpec,
        Ports: []const EndpointPortConfig,
        VirtualIPs: []const struct {
            NetworkID: string,
            Addr: string,
        },
    },
    UpdateStatus: struct {
        State: enum {
            updating,
            paused,
            completed,
        },
        StartedAt: string,
        CompletedAt: string,
        Message: string,
    },
    ServiceStatus: struct {
        RunningTasks: i32,
        DesiredTasks: i32,
        CompletedTasks: i32,
    },
    JobStatus: struct {
        JobIteration: ObjectVersion,
        LastExecution: string,
    },
};

pub const ImageDeleteResponseItem = struct {
    Untagged: string,
    Deleted: string,
};

pub const ServiceUpdateResponse = struct {
    Warnings: []const string,
};

pub const ContainerSummary = struct {
    Id: string,
    Names: []const string,
    Image: string,
    ImageID: string,
    Command: string,
    Created: i32,
    Ports: []const Port,
    SizeRw: i32,
    SizeRootFs: i32,
    Labels: struct {},
    State: string,
    Status: string,
    HostConfig: struct {
        NetworkMode: string,
    },
    NetworkSettings: struct {
        Networks: struct {},
    },
    Mounts: []const Mount,
};

pub const Driver = struct {
    Name: string,
    Options: struct {},
};

pub const SecretSpec = struct {
    Name: string,
    Labels: struct {},
    Data: string,
    Driver: Driver,
    Templating: Driver,
};

pub const Secret = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: SecretSpec,
};

pub const ConfigSpec = struct {
    Name: string,
    Labels: struct {},
    Data: string,
    Templating: Driver,
};

pub const Config = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: ConfigSpec,
};

pub const ContainerState = struct {
    Status: enum {
        created,
        running,
        paused,
        restarting,
        removing,
        exited,
        dead,
    },
    Running: bool,
    Paused: bool,
    Restarting: bool,
    OOMKilled: bool,
    Dead: bool,
    Pid: i32,
    ExitCode: i32,
    Error: string,
    StartedAt: string,
    FinishedAt: string,
    Health: Health,
};

pub const SystemVersion = struct {
    Platform: struct {
        Name: string,
    },
    Components: []const struct {
        Name: string,
        Version: string,
        Details: struct {},
    },
    Version: string,
    ApiVersion: string,
    MinAPIVersion: string,
    GitCommit: string,
    GoVersion: string,
    Os: string,
    Arch: string,
    KernelVersion: string,
    Experimental: bool,
    BuildTime: string,
};

pub const SystemInfo = struct {
    ID: string,
    Containers: i32,
    ContainersRunning: i32,
    ContainersPaused: i32,
    ContainersStopped: i32,
    Images: i32,
    Driver: string,
    DriverStatus: []const []const string,
    DockerRootDir: string,
    Plugins: PluginsInfo,
    MemoryLimit: bool,
    SwapLimit: bool,
    KernelMemory: bool,
    CpuCfsPeriod: bool,
    CpuCfsQuota: bool,
    CPUShares: bool,
    CPUSet: bool,
    PidsLimit: bool,
    OomKillDisable: bool,
    IPv4Forwarding: bool,
    BridgeNfIptables: bool,
    BridgeNfIp6tables: bool,
    Debug: bool,
    NFd: i32,
    NGoroutines: i32,
    SystemTime: string,
    LoggingDriver: string,
    CgroupDriver: enum {
        cgroupfs,
        systemd,
        none,
    },
    CgroupVersion: enum {
        @"1",
        @"2",
    },
    NEventsListener: i32,
    KernelVersion: string,
    OperatingSystem: string,
    OSVersion: string,
    OSType: string,
    Architecture: string,
    NCPU: i32,
    MemTotal: i32,
    IndexServerAddress: string,
    RegistryConfig: RegistryServiceConfig,
    GenericResources: GenericResources,
    HttpProxy: string,
    HttpsProxy: string,
    NoProxy: string,
    Name: string,
    Labels: []const string,
    ExperimentalBuild: bool,
    ServerVersion: string,
    ClusterStore: string,
    ClusterAdvertise: string,
    Runtimes: struct {},
    DefaultRuntime: string,
    Swarm: SwarmInfo,
    LiveRestoreEnabled: bool,
    Isolation: enum {
        default,
        hyperv,
        process,
    },
    InitBinary: string,
    ContainerdCommit: Commit,
    RuncCommit: Commit,
    InitCommit: Commit,
    SecurityOptions: []const string,
    ProductLicense: string,
    DefaultAddressPools: []const struct {
        Base: string,
        Size: i32,
    },
    Warnings: []const string,
};

pub const PluginsInfo = struct {
    Volume: []const string,
    Network: []const string,
    Authorization: []const string,
    Log: []const string,
};

pub const RegistryServiceConfig = struct {
    AllowNondistributableArtifactsCIDRs: []const string,
    AllowNondistributableArtifactsHostnames: []const string,
    InsecureRegistryCIDRs: []const string,
    IndexConfigs: struct {},
    Mirrors: []const string,
};

pub const IndexInfo = struct {
    Name: string,
    Mirrors: []const string,
    Secure: bool,
    Official: bool,
};

pub const Runtime = struct {
    path: string,
    runtimeArgs: []const string,
};

pub const Commit = struct {
    ID: string,
    Expected: string,
};

pub const SwarmInfo = struct {
    NodeID: string,
    NodeAddr: string,
    LocalNodeState: LocalNodeState,
    ControlAvailable: bool,
    Error: string,
    RemoteManagers: []const PeerNode,
    Nodes: i32,
    Managers: i32,
    Cluster: ClusterInfo,
};

pub const LocalNodeState = enum {
    inactive,
    pending,
    active,
    @"error",
    locked,
};

pub const PeerNode = struct {
    NodeID: string,
    Addr: string,
};

pub const NetworkAttachmentConfig = struct {
    Target: string,
    Aliases: []const string,
    DriverOpts: struct {},
};

pub const EventActor = struct {
    ID: string,
    Attributes: struct {},
};

pub const EventMessage = struct {
    Type: enum {
        builder,
        config,
        container,
        daemon,
        image,
        network,
        node,
        plugin,
        secret,
        service,
        volume,
    },
    Action: string,
    Actor: EventActor,
    scope: enum {
        local,
        swarm,
    },
    time: i32,
    timeNano: i32,
};

pub const OCIDescriptor = struct {
    mediaType: string,
    digest: string,
    size: i32,
};

pub const OCIPlatform = struct {
    architecture: string,
    os: string,
    @"os.version": string,
    @"os.features": []const string,
    variant: string,
};

pub const DistributionInspect = struct {
    Descriptor: OCIDescriptor,
    Platforms: []const OCIPlatform,
};
