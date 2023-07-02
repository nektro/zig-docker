const internal = @import("./internal.zig");
const string = []const u8;
const Top = @This();

pub const Port = struct {
    IP: ?string = null,
    PrivatePort: i32,
    PublicPort: ?i32 = null,
    Type: enum {
        tcp,
        udp,
        sctp,
    },
};

pub const MountPoint = struct {
    Type: enum {
        bind,
        volume,
        tmpfs,
        npipe,
        cluster,
    },
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
        cluster,
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
        CreateMountpoint: bool,
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
        ConsoleSize: []const i32,
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

pub const ImageInspect = struct {
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
    Variant: string,
    Os: string,
    OsVersion: string,
    Size: i32,
    VirtualSize: i32,
    GraphDriver: GraphDriverData,
    RootFS: struct {
        Type: string,
        Layers: ?[]const string = null,
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
    CreatedAt: ?string = null,
    Status: ?struct {} = null,
    Labels: struct {},
    Scope: enum {
        local,
        global,
    },
    ClusterVolume: ?ClusterVolume = null,
    Options: struct {},
    UsageData: ?struct {
        Size: i32,
        RefCount: i32,
    } = null,
};

pub const VolumeCreateOptions = struct {
    Name: string,
    Driver: string,
    DriverOpts: struct {},
    Labels: struct {},
    ClusterVolumeSpec: ClusterVolumeSpec,
};

pub const VolumeListResponse = struct {
    Volumes: []const Volume,
    Warnings: []const string,
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
    Config: []const IPAMConfig,
    Options: struct {},
};

pub const IPAMConfig = struct {
    Subnet: string,
    IPRange: string,
    Gateway: string,
    AuxiliaryAddresses: struct {},
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
    Parents: []const string,
    Type: enum {
        internal,
        frontend,
        @"source.local",
        @"source.git.checkout",
        @"exec.cachemount",
        regular,
    },
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
    errorDetail: ErrorDetail,
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
    Id: ?string = null,
    Name: string,
    Enabled: bool,
    Settings: struct {
        Mounts: []const PluginMount,
        Env: []const string,
        Args: []const string,
        Devices: []const PluginDevice,
    },
    PluginReference: ?string = null,
    Config: struct {
        DockerVersion: ?string = null,
        Description: string,
        Documentation: string,
        Interface: struct {
            Types: []const PluginInterfaceType,
            Socket: string,
            ProtocolScheme: ?enum {
                @"moby.plugins.http/v1",
            } = null,
        },
        Entrypoint: []const string,
        WorkDir: string,
        User: ?struct {
            UID: i32,
            GID: i32,
        } = null,
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
        rootfs: ?struct {
            type: string,
            diff_ids: []const string,
        } = null,
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
        Reservations: ResourceObject,
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
    Mounts: []const MountPoint,
};

pub const Driver = struct {
    Name: string,
    Options: ?struct {} = null,
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

pub const ContainerCreateResponse = struct {
    Id: string,
    Warnings: []const string,
};

pub const ContainerWaitResponse = struct {
    StatusCode: i32,
    Error: ?ContainerWaitExitError = null,
};

pub const ContainerWaitExitError = struct {
    Message: string,
};

pub const SystemVersion = struct {
    Platform: struct {
        Name: string,
    },
    Components: []const struct {
        Name: string,
        Version: string,
        Details: ?struct {} = null,
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
    KernelMemoryTCP: bool,
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

pub const ClusterVolume = struct {
    ID: string,
    Version: ObjectVersion,
    CreatedAt: string,
    UpdatedAt: string,
    Spec: ClusterVolumeSpec,
    Info: struct {
        CapacityBytes: i32,
        VolumeContext: struct {},
        VolumeID: string,
        AccessibleTopology: []const Topology,
    },
    PublishStatus: []const struct {
        NodeID: string,
        State: enum {
            @"pending-publish",
            published,
            @"pending-node-unpublish",
            @"pending-controller-unpublish",
        },
        PublishContext: struct {},
    },
};

pub const ClusterVolumeSpec = struct {
    Group: string,
    AccessMode: struct {
        Scope: enum {
            single,
            multi,
        },
        Sharing: enum {
            none,
            readonly,
            onewriter,
            all,
        },
        MountVolume: struct {},
        Secrets: []const struct {
            Key: string,
            Secret: string,
        },
        AccessibilityRequirements: struct {
            Requisite: []const Topology,
            Preferred: []const Topology,
        },
        CapacityRange: struct {
            RequiredBytes: i32,
            LimitBytes: i32,
        },
        Availability: enum {
            active,
            pause,
            drain,
        },
    },
};

pub const Topology = struct {};

pub const @"/containers/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { all: bool = false, limit: i32, size: bool = false, filters: string },
        void,
        union(enum) {
            @"200": []const ContainerSummary,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { name: string, platform: string = "" },
        struct { body: internal.AllOf(&.{ ContainerConfig, struct { HostConfig: HostConfig, NetworkingConfig: NetworkingConfig } }) },
        union(enum) {
            @"201": ContainerCreateResponse,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { size: bool = false },
        void,
        union(enum) {
            @"200": struct { Id: string, Created: string, Path: string, Args: []const string, State: ContainerState, Image: string, ResolvConfPath: string, HostnamePath: string, HostsPath: string, LogPath: string, Name: string, RestartCount: i32, Driver: string, Platform: string, MountLabel: string, ProcessLabel: string, AppArmorProfile: string, ExecIDs: []const string, HostConfig: HostConfig, GraphDriver: GraphDriverData, SizeRw: i32, SizeRootFs: i32, Mounts: []const MountPoint, Config: ContainerConfig, NetworkSettings: NetworkSettings },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/top" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { ps_args: string = "-ef" },
        void,
        union(enum) {
            @"200": struct { Titles: []const string, Processes: []const []const string },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/logs" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { follow: bool = false, stdout: bool = false, stderr: bool = false, since: i32 = 0, until: i32 = 0, timestamps: bool = false, tail: string = "all" },
        void,
        union(enum) {
            @"200": string,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/changes" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": []const struct { Path: string, Kind: i32 },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/export" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": []const u8,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/stats" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { stream: bool = true, @"one-shot": bool = false },
        void,
        union(enum) {
            @"200": struct {},
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/resize" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { h: i32, w: i32 },
        void,
        union(enum) {
            @"200": []const u8,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/start" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { detachKeys: string },
        void,
        union(enum) {
            @"204": void,
            @"304": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/stop" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { signal: string, t: i32 },
        void,
        union(enum) {
            @"204": void,
            @"304": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/restart" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { signal: string, t: i32 },
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/kill" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { signal: string = "SIGKILL" },
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        struct { update: internal.AllOf(&.{ Resources, struct { RestartPolicy: RestartPolicy } }) },
        union(enum) {
            @"200": struct { Warnings: []const string },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/rename" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { name: string },
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/pause" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/unpause" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/attach" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { detachKeys: string, logs: bool = false, stream: bool = false, stdin: bool = false, stdout: bool = false, stderr: bool = false },
        void,
        union(enum) {
            @"101": void,
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/attach/ws" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { detachKeys: string, logs: bool = false, stream: bool = false, stdin: bool = false, stdout: bool = false, stderr: bool = false },
        void,
        union(enum) {
            @"101": void,
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/wait" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { condition: enum {
            @"not-running",
            @"next-exit",
            removed,
        } = "not-running" },
        void,
        union(enum) {
            @"200": ContainerWaitResponse,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}" = struct {
    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        struct { v: bool = false, force: bool = false, link: bool = false },
        void,
        union(enum) {
            @"204": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/archive" = struct {
    pub usingnamespace internal.Fn(
        .head,
        internal.name(Top, @This()),
        struct { id: string },
        struct { path: string },
        void,
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { path: string },
        void,
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .put,
        internal.name(Top, @This()),
        struct { id: string },
        struct { path: string, noOverwriteDirNonDir: string, copyUIDGID: string },
        struct { inputStream: string },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"403": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/prune" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": struct { ContainersDeleted: []const string, SpaceReclaimed: i32 },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { all: bool = false, filters: string, @"shared-size": bool = false, digests: bool = false },
        void,
        union(enum) {
            @"200": []const ImageSummary,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/build" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { dockerfile: string = "Dockerfile", t: string, extrahosts: string, remote: string, q: bool = false, nocache: bool = false, cachefrom: string, pull: string, rm: bool = true, forcerm: bool = false, memory: i32, memswap: i32, cpushares: i32, cpusetcpus: string, cpuperiod: i32, cpuquota: i32, buildargs: string, shmsize: i32, squash: bool, labels: string, networkmode: string, platform: string = "", target: string = "", outputs: string = "" },
        struct { inputStream: string },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/build/prune" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { @"keep-storage": i32, all: bool, filters: string },
        void,
        union(enum) {
            @"200": struct { CachesDeleted: []const string, SpaceReclaimed: i32 },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { fromImage: string, fromSrc: string, repo: string, tag: string, message: string, changes: []const string, platform: string = "" },
        struct { inputImage: string },
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": ImageInspect,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}/history" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": []const struct { Id: string, Created: i32, CreatedBy: string, Tags: []const string, Size: i32, Comment: string },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}/push" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        struct { tag: string },
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}/tag" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        struct { repo: string, tag: string },
        void,
        union(enum) {
            @"201": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}" = struct {
    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { name: string },
        struct { force: bool = false, noprune: bool = false },
        void,
        union(enum) {
            @"200": []const ImageDeleteResponseItem,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/search" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { term: string, limit: i32, filters: string },
        void,
        union(enum) {
            @"200": []const struct { description: string, is_official: bool, is_automated: bool, name: string, star_count: i32 },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/prune" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": struct { ImagesDeleted: []const ImageDeleteResponseItem, SpaceReclaimed: i32 },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/auth" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { authConfig: AuthConfig },
        union(enum) {
            @"200": struct { Status: string, IdentityToken: ?string = null },
            @"204": void,
            @"401": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/info" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": SystemInfo,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/version" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": SystemVersion,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/_ping" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": string,
            @"500": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .head,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": string,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/commit" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { container: string, repo: string, tag: string, comment: string, author: string, pause: bool = true, changes: string },
        struct { containerConfig: ContainerConfig },
        union(enum) {
            @"201": IdResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/events" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { since: string, until: string, filters: string },
        void,
        union(enum) {
            @"200": EventMessage,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/system/df" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { type: []const enum {
            container,
            image,
            volume,
            @"build-cache",
        } },
        void,
        union(enum) {
            @"200": struct { LayersSize: i32, Images: []const ImageSummary, Containers: []const ContainerSummary, Volumes: []const Volume, BuildCache: []const BuildCache },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/{name}/get" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": string,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/get" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { names: []const string },
        void,
        union(enum) {
            @"200": string,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/images/load" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { quiet: bool = false },
        struct { imagesTarball: string },
        union(enum) {
            @"200": void,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/containers/{id}/exec" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        struct { execConfig: struct { AttachStdin: bool, AttachStdout: bool, AttachStderr: bool, ConsoleSize: []const i32, DetachKeys: string, Tty: bool, Env: []const string, Cmd: []const string, Privileged: bool, User: string, WorkingDir: string } },
        union(enum) {
            @"201": IdResponse,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/exec/{id}/start" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        struct { execStartConfig: struct { Detach: bool, Tty: bool, ConsoleSize: []const i32 } },
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
        },
    );
};

pub const @"/exec/{id}/resize" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { h: i32, w: i32 },
        void,
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/exec/{id}/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": struct { CanRemove: bool, DetachKeys: string, ID: string, Running: bool, ExitCode: i32, ProcessConfig: ProcessConfig, OpenStdin: bool, OpenStderr: bool, OpenStdout: bool, ContainerID: string, Pid: i32 },
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/volumes" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": VolumeListResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/volumes/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { volumeConfig: VolumeCreateOptions },
        union(enum) {
            @"201": Volume,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/volumes/{name}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": Volume,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .put,
        internal.name(Top, @This()),
        struct { name: string },
        struct { version: i32 },
        struct { body: struct { Spec: ClusterVolumeSpec } },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { name: string },
        struct { force: bool = false },
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/volumes/prune" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": struct { VolumesDeleted: []const string, SpaceReclaimed: i32 },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Network,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { verbose: bool = false, scope: string },
        void,
        union(enum) {
            @"200": Network,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"204": void,
            @"403": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { networkConfig: struct { Name: string, CheckDuplicate: ?bool = null, Driver: ?string = null, Internal: ?bool = null, Attachable: ?bool = null, Ingress: ?bool = null, IPAM: ?IPAM = null, EnableIPv6: ?bool = null, Options: ?struct {} = null, Labels: ?struct {} = null } },
        union(enum) {
            @"201": struct { Id: string, Warning: string },
            @"403": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks/{id}/connect" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        struct { container: struct { Container: string, EndpointConfig: EndpointSettings } },
        union(enum) {
            @"200": void,
            @"403": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks/{id}/disconnect" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        struct { container: struct { Container: string, Force: bool } },
        union(enum) {
            @"200": void,
            @"403": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/networks/prune" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": struct { NetworksDeleted: []const string },
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Plugin,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/privileges" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { remote: string },
        void,
        union(enum) {
            @"200": []const PluginPrivilege,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/pull" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { remote: string, name: string },
        struct { body: []const PluginPrivilege },
        union(enum) {
            @"204": void,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": Plugin,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}" = struct {
    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { name: string },
        struct { force: bool = false },
        void,
        union(enum) {
            @"200": Plugin,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/enable" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        struct { timeout: i32 = 0 },
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/disable" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/upgrade" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        struct { remote: string },
        struct { body: []const PluginPrivilege },
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { name: string },
        struct { tarContext: string },
        union(enum) {
            @"204": void,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/push" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/plugins/{name}/set" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        struct { body: []const string },
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/nodes" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Node,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/nodes/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": Node,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        struct { force: bool = false },
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/nodes/{id}/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { version: i32 },
        struct { body: NodeSpec },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": Swarm,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/init" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: struct { ListenAddr: string, AdvertiseAddr: string, DataPathAddr: string, DataPathPort: i32, DefaultAddrPool: []const string, ForceNewCluster: bool, SubnetSize: i32, Spec: SwarmSpec } },
        union(enum) {
            @"200": string,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/join" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: struct { ListenAddr: string, AdvertiseAddr: string, DataPathAddr: string, RemoteAddrs: []const string, JoinToken: string } },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/leave" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { force: bool = false },
        void,
        union(enum) {
            @"200": void,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        struct { version: i32, rotateWorkerToken: bool = false, rotateManagerToken: bool = false, rotateManagerUnlockKey: bool = false },
        struct { body: SwarmSpec },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/unlockkey" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"200": struct { UnlockKey: string },
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/swarm/unlock" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: struct { UnlockKey: string } },
        union(enum) {
            @"200": void,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/services" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string, status: bool },
        void,
        union(enum) {
            @"200": []const Service,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/services/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: internal.AllOf(&.{ ServiceSpec, struct {} }) },
        union(enum) {
            @"201": struct { ID: string, Warning: string },
            @"400": ErrorResponse,
            @"403": ErrorResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/services/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { insertDefaults: bool = false },
        void,
        union(enum) {
            @"200": Service,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/services/{id}/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { version: i32, registryAuthFrom: enum {
            spec,
            @"previous-spec",
        } = "spec", rollback: string },
        struct { body: internal.AllOf(&.{ ServiceSpec, struct {} }) },
        union(enum) {
            @"200": ServiceUpdateResponse,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/services/{id}/logs" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { details: bool = false, follow: bool = false, stdout: bool = false, stderr: bool = false, since: i32 = 0, timestamps: bool = false, tail: string = "all" },
        void,
        union(enum) {
            @"200": string,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/tasks" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Task,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/tasks/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": Task,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/tasks/{id}/logs" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        struct { details: bool = false, follow: bool = false, stdout: bool = false, stderr: bool = false, since: i32 = 0, timestamps: bool = false, tail: string = "all" },
        void,
        union(enum) {
            @"200": string,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/secrets" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Secret,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/secrets/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: internal.AllOf(&.{ SecretSpec, struct {} }) },
        union(enum) {
            @"201": IdResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/secrets/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": Secret,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/secrets/{id}/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { version: i32 },
        struct { body: SecretSpec },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/configs" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        void,
        struct { filters: string },
        void,
        union(enum) {
            @"200": []const Config,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/configs/create" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        struct { body: internal.AllOf(&.{ ConfigSpec, struct {} }) },
        union(enum) {
            @"201": IdResponse,
            @"409": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/configs/{id}" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"200": Config,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );

    pub usingnamespace internal.Fn(
        .delete,
        internal.name(Top, @This()),
        struct { id: string },
        void,
        void,
        union(enum) {
            @"204": void,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/configs/{id}/update" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        struct { id: string },
        struct { version: i32 },
        struct { body: ConfigSpec },
        union(enum) {
            @"200": void,
            @"400": ErrorResponse,
            @"404": ErrorResponse,
            @"500": ErrorResponse,
            @"503": ErrorResponse,
        },
    );
};

pub const @"/distribution/{name}/json" = struct {
    pub usingnamespace internal.Fn(
        .get,
        internal.name(Top, @This()),
        struct { name: string },
        void,
        void,
        union(enum) {
            @"200": DistributionInspect,
            @"401": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};

pub const @"/session" = struct {
    pub usingnamespace internal.Fn(
        .post,
        internal.name(Top, @This()),
        void,
        void,
        void,
        union(enum) {
            @"101": void,
            @"400": ErrorResponse,
            @"500": ErrorResponse,
        },
    );
};
