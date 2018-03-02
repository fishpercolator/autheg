<template>
  <section class="container">
    <div class="example" v-for="example in examples" :key="example.id" :style="`color:${example.colour}`">
      {{example.name}}
    </div>
  </section>
</template>

<script>

export default {
  data () {
    return {
      examples: []
    }
  },
  methods: {
    async updateExamples() {
      this.examples = await this.$axios.$get('/examples')
    }
  },
  mounted () {
    this.updateExamples()
  }
}
</script>

<style>
.example {
  margin: 0.5em;
  padding: 0.5em;
  border: 1px solid currentColor;
}
</style>
