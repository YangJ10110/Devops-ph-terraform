variable "ebs_volume" {
    description = "EBS volume configuration"
    type = object({
        size                 = number
        type                 = string
        iops                 = number
        encrypted            = bool
        kms_key_id           = string
        delete_on_termination = bool
    })
    default = {
        size                 = 20
        type                 = "gp2"
        iops                 = 100
        encrypted            = false
        kms_key_id           = ""
        delete_on_termination = true
    }
}
